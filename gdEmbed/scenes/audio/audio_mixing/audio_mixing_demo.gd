extends AudioDemoPlayer

# Audio Mixing Demo - Multiple audio sources and bus routing
# Demonstrates AudioBusLayout, AudioStreamPlayer mixing, and bus effects

var audio_players: Array[AudioStreamPlayer] = []
var audio_streams: Array[AudioStream] = []
var master_bus: int
var music_bus: int
var sfx_bus: int
var is_playing := false

func get_demo_title() -> String:
	return "Audio Mixing - Multiple Sources & Buses"

func get_demo_description() -> String:
	return "Learn to mix multiple audio sources using AudioBusLayout. Control different audio buses (Master, Music, SFX) with individual volume controls. Uses Sample playback mode for low latency."

func setup_demo_specific():
	# Load audio files
	load_audio_streams()
	
	if audio_streams.size() > 0:
		setup_audio_buses()
		setup_audio_players()
		create_playback_controls()
		create_bus_controls()
		create_individual_controls()
		show_audio_info()
	else:
		show_error("Failed to load audio files")

func load_audio_streams():
	var audio_files = [
		"res://assets/audio/1_bar_120bpm_ripplerx-malletripplerx-mallet.wav",
		"res://assets/audio/1_bar_120bpm_surge-dreamssurge-dreams.wav"
	]
	
	for file_path in audio_files:
		var stream = load_audio_resource(file_path)
		if stream:
			audio_streams.append(stream)
		else:
			print("Failed to load: ", file_path)

func setup_audio_buses():
	# Get existing buses or create them
	master_bus = AudioServer.get_bus_index("Master")
	
	# Add music bus if it doesn't exist
	music_bus = AudioServer.get_bus_index("Music")
	if music_bus == -1:
		AudioServer.add_bus(1)  # Add after Master
		AudioServer.set_bus_name(1, "Music")
		AudioServer.set_bus_send(1, "Master")
		music_bus = 1
	
	# Add SFX bus if it doesn't exist
	sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		var sfx_index = AudioServer.get_bus_count()
		AudioServer.add_bus(sfx_index)
		AudioServer.set_bus_name(sfx_index, "SFX")
		AudioServer.set_bus_send(sfx_index, "Master")
		sfx_bus = sfx_index

func setup_audio_players():
	# Create AudioStreamPlayer for each audio stream
	for i in range(audio_streams.size()):
		var player = AudioStreamPlayer.new()
		player.stream = audio_streams[i]
		player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
		
		# Route to different buses
		if i == 0:
			player.bus = "Music"
		else:
			player.bus = "SFX"
		
		add_child(player)
		audio_players.append(player)

func create_playback_controls():
	var controls_container = HBoxContainer.new()
	ui_container.add_child(controls_container)
	
	# Play All button
	var play_all_button = create_button("Play All", _on_play_all_pressed)
	controls_container.add_child(play_all_button)
	
	# Stop All button
	var stop_all_button = create_button("Stop All", _on_stop_all_pressed)
	controls_container.add_child(stop_all_button)
	
	# Loop toggle
	var loop_button = create_button("Loop: OFF", _on_loop_pressed)
	controls_container.add_child(loop_button)

func create_bus_controls():
	var bus_label = Label.new()
	bus_label.text = "\nBus Controls:"
	ui_container.add_child(bus_label)
	
	# Master bus volume
	var master_container = create_labeled_slider("Master Volume", -30.0, 10.0, 0.0, _on_master_volume_changed)
	ui_container.add_child(master_container)
	
	# Music bus volume
	var music_container = create_labeled_slider("Music Bus Volume", -30.0, 10.0, -5.0, _on_music_volume_changed)
	ui_container.add_child(music_container)
	
	# SFX bus volume
	var sfx_container = create_labeled_slider("SFX Bus Volume", -30.0, 10.0, -5.0, _on_sfx_volume_changed)
	ui_container.add_child(sfx_container)
	
	# Set initial bus volumes
	AudioServer.set_bus_volume_db(master_bus, 0.0)
	AudioServer.set_bus_volume_db(music_bus, -5.0)
	AudioServer.set_bus_volume_db(sfx_bus, -5.0)

func create_individual_controls():
	var individual_label = Label.new()
	individual_label.text = "\nIndividual Player Controls:"
	ui_container.add_child(individual_label)
	
	for i in range(audio_players.size()):
		var player = audio_players[i]
		var container = HBoxContainer.new()
		ui_container.add_child(container)
		
		# Player label
		var label = Label.new()
		label.text = "Track %d (%s): " % [i + 1, player.bus]
		label.custom_minimum_size = Vector2(120, 0)
		container.add_child(label)
		
		# Play button
		var play_button = create_button("Play", func(): _on_individual_play_pressed(i))
		container.add_child(play_button)
		
		# Stop button
		var stop_button = create_button("Stop", func(): _on_individual_stop_pressed(i))
		container.add_child(stop_button)
		
		# Volume slider
		var volume_slider = create_slider(-30.0, 0.0, -10.0, func(value): _on_individual_volume_changed(i, value))
		container.add_child(volume_slider)
		
		# Volume label
		var volume_label = Label.new()
		volume_label.text = "-10dB"
		container.add_child(volume_label)
		
		# Connect slider to update label
		volume_slider.value_changed.connect(func(value): volume_label.text = "%.1fdB" % value)
		
		# Set initial volume
		player.volume_db = -10.0

func show_audio_info():
	var info_label = Label.new()
	info_label.text = "Audio Mixing Info:\n• %d audio tracks loaded\n• 3 audio buses: Master, Music, SFX\n• Playback Type: Sample (Low Latency)\n• Bus routing for organized audio management" % audio_streams.size()
	ui_container.add_child(info_label)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "\nInstructions:\n• Use 'Play All' to start all tracks simultaneously\n• Control bus volumes to mix different audio categories\n• Individual controls allow per-track manipulation\n• Master bus affects all audio output\n• Use keyboard: 1=Play All, 2=Stop All, 3=Loop"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(instructions)

func show_error(message: String):
	var error_label = Label.new()
	error_label.text = "Error: " + message
	error_label.add_theme_color_override("font_color", Color.RED)
	ui_container.add_child(error_label)

func _on_play_all_pressed():
	for player in audio_players:
		if not player.playing:
			player.play()
	is_playing = true
	print("All audio tracks started playing")

func _on_stop_all_pressed():
	for player in audio_players:
		player.stop()
	is_playing = false
	print("All audio tracks stopped")

func _on_loop_pressed():
	var loop_enabled = false
	for player in audio_players:
		if player.stream and player.stream is AudioStreamWAV:
			var stream = player.stream as AudioStreamWAV
			var new_mode = AudioStreamWAV.LOOP_FORWARD if stream.loop_mode == AudioStreamWAV.LOOP_DISABLED else AudioStreamWAV.LOOP_DISABLED
			stream.loop_mode = new_mode
			loop_enabled = new_mode != AudioStreamWAV.LOOP_DISABLED
	
	var loop_text = "Loop: ON" if loop_enabled else "Loop: OFF"
	# Update button text
	for child in ui_container.get_children():
		if child is HBoxContainer:
			for button in child.get_children():
				if button is Button and button.text.begins_with("Loop:"):
					button.text = loop_text
					break

func _on_individual_play_pressed(index: int):
	if index < audio_players.size():
		audio_players[index].play()
		print("Track %d started playing" % (index + 1))

func _on_individual_stop_pressed(index: int):
	if index < audio_players.size():
		audio_players[index].stop()
		print("Track %d stopped" % (index + 1))

func _on_individual_volume_changed(index: int, value: float):
	if index < audio_players.size():
		audio_players[index].volume_db = value

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(master_bus, value)

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, value)

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, value)

func _input(event):
	if event.is_action_pressed("ui_1"):  # 1 key
		_on_play_all_pressed()
	elif event.is_action_pressed("ui_2"):  # 2 key
		_on_stop_all_pressed()
	elif event.is_action_pressed("ui_3"):  # 3 key
		_on_loop_pressed()
