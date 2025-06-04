extends AudioDemoPlayer

# OGG Audio Demo - OGG Vorbis file loading and playback
# Demonstrates compressed audio streaming and advanced playback features

var audio_player: AudioStreamPlayer
var ogg_stream: AudioStream
var is_playing := false
var playback_position := 0.0

func get_demo_title() -> String:
	return "OGG Vorbis Audio Playback"

func get_demo_description() -> String:
	return "Learn how to load and play OGG Vorbis compressed audio files. OGG provides smaller file sizes with good quality, ideal for music and longer audio clips in web games."

func setup_demo_specific():
	# Load OGG audio file
	ogg_stream = load_audio_resource("res://assets/audio/1_bar_120bpm_surge-dreamssurge-dreams.ogg")
	
	if ogg_stream:
		audio_player = create_audio_player(ogg_stream)
		create_playback_controls()
		create_audio_controls()
		create_seek_controls()
		show_audio_info()
		
		# Update playback position display
		var timer = Timer.new()
		timer.wait_time = 0.1
		timer.timeout.connect(_update_position)
		timer.autostart = true
		add_child(timer)
	else:
		show_error("Failed to load OGG audio file")

func create_playback_controls():
	var controls_container = HBoxContainer.new()
	ui_container.add_child(controls_container)
	
	# Play/Pause button
	var play_button = create_button("Play", _on_play_pressed)
	controls_container.add_child(play_button)
	
	# Pause button
	var pause_button = create_button("Pause", _on_pause_pressed)
	controls_container.add_child(pause_button)
	
	# Stop button
	var stop_button = create_button("Stop", _on_stop_pressed)
	controls_container.add_child(stop_button)
	
	# Loop toggle
	var loop_button = create_button("Loop: OFF", _on_loop_pressed)
	controls_container.add_child(loop_button)

func create_audio_controls():
	# Volume control
	var volume_container = create_labeled_slider("Volume", -30.0, 6.0, -5.0, _on_volume_changed)
	ui_container.add_child(volume_container)
	
	# Pitch control
	var pitch_container = create_labeled_slider("Pitch Scale", 0.25, 4.0, 1.0, _on_pitch_changed)
	ui_container.add_child(pitch_container)
	
	# Set initial values
	audio_player.volume_db = -5.0
	audio_player.pitch_scale = 1.0

func create_seek_controls():
	var seek_container = VBoxContainer.new()
	ui_container.add_child(seek_container)
	
	var seek_label = Label.new()
	seek_label.text = "Seek Position"
	seek_container.add_child(seek_label)
	
	var seek_slider = HSlider.new()
	seek_slider.min_value = 0.0
	seek_slider.max_value = ogg_stream.get_length() if ogg_stream else 1.0
	seek_slider.step = 0.1
	seek_slider.value_changed.connect(_on_seek_changed)
	seek_container.add_child(seek_slider)
	
	var position_label = Label.new()
	position_label.name = "PositionLabel"
	position_label.text = "0.0 / %.1f seconds" % (ogg_stream.get_length() if ogg_stream else 0.0)
	seek_container.add_child(position_label)

func show_audio_info():
	var info_label = Label.new()
	var length = ogg_stream.get_length() if ogg_stream else 0.0
	info_label.text = "Audio Info:\n• Format: OGG Vorbis (Compressed)\n• Length: %.2f seconds\n• File size: Smaller than WAV\n• Quality: Good compression" % length
	ui_container.add_child(info_label)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "\nInstructions:\n• Keys 1/2/3: Play/Pause/Stop\n• Use seek slider to jump to any position\n• OGG files are compressed for smaller download sizes\n• Ideal for background music and longer audio clips"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(instructions)

func show_error(message: String):
	var error_label = Label.new()
	error_label.text = "Error: " + message
	error_label.add_theme_color_override("font_color", Color.RED)
	ui_container.add_child(error_label)

func _update_position():
	if audio_player and is_playing:
		playback_position = audio_player.get_playback_position()
		var position_label = ui_container.find_child("PositionLabel", true, false)
		if position_label:
			var total_length = ogg_stream.get_length() if ogg_stream else 0.0
			position_label.text = "%.1f / %.1f seconds" % [playback_position, total_length]
		
		# Update seek slider without triggering callback
		for child in ui_container.get_children():
			if child is VBoxContainer:
				for grandchild in child.get_children():
					if grandchild is HSlider:
						grandchild.set_value_no_signal(playback_position)

func _on_play_pressed():
	if audio_player:
		if not is_playing:
			audio_player.play(playback_position)
			is_playing = true
			print("OGG audio started playing from position: ", playback_position)

func _on_pause_pressed():
	if audio_player and is_playing:
		playback_position = audio_player.get_playback_position()
		audio_player.stop()
		is_playing = false
		print("OGG audio paused at position: ", playback_position)

func _on_stop_pressed():
	if audio_player:
		audio_player.stop()
		is_playing = false
		playback_position = 0.0
		print("OGG audio stopped")

func _on_loop_pressed():
	if audio_player and audio_player.stream:
		var stream = audio_player.stream as AudioStreamOggVorbis
		if stream:
			stream.loop = not stream.loop
			var loop_text = "Loop: ON" if stream.loop else "Loop: OFF"
			# Update button text
			for child in ui_container.get_children():
				if child is HBoxContainer:
					for button in child.get_children():
						if button is Button and button.text.begins_with("Loop:"):
							button.text = loop_text
							break

func _on_volume_changed(value: float):
	if audio_player:
		audio_player.volume_db = value

func _on_pitch_changed(value: float):
	if audio_player:
		audio_player.pitch_scale = value

func _on_seek_changed(value: float):
	if audio_player:
		playback_position = value
		if is_playing:
			audio_player.play(playback_position)

func _input(event):
	if event.is_action_pressed("ui_1"):  # 1 key
		_on_play_pressed()
	elif event.is_action_pressed("ui_2"):  # 2 key
		_on_pause_pressed()
	elif event.is_action_pressed("ui_3"):  # 3 key
		_on_stop_pressed()
	elif event.is_action_pressed("ui_4"):  # 4 key
		_on_loop_pressed()
