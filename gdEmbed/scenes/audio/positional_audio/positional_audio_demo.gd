extends AudioDemoPlayer

# Positional Audio Demo - 3D audio positioning and effects
# Demonstrates AudioStreamPlayer2D for spatial audio positioning

var audio_player: AudioStreamPlayer2D
var listener: AudioListener2D
var wav_stream: AudioStream
var is_playing := false
var source_position := Vector2(0, 0)

func get_demo_title() -> String:
	return "Positional Audio - 2D Spatial Sound"

func get_demo_description() -> String:
	return "Experience positional audio with AudioStreamPlayer2D. Move the sound source around to hear how audio changes based on position. Uses Sample playback mode for low latency."

func setup_demo_specific():
	# Load audio file
	wav_stream = load_audio_resource("res://assets/audio/1_bar_120bpm_ripplerx-malletripplerx-mallet.wav")
	
	if wav_stream:
		setup_audio_player()
		create_playback_controls()
		create_position_controls()
		create_visualization()
		show_audio_info()
	else:
		show_error("Failed to load audio file")

func setup_audio_player():
	# Create AudioStreamPlayer2D for positional audio
	audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = wav_stream
	audio_player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
	
	# Configure positional audio settings
	audio_player.max_distance = 300.0
	audio_player.attenuation = 1.0
	audio_player.panning_strength = 1.0
	
	add_child(audio_player)
	
	# Set initial position
	audio_player.position = source_position

func create_playback_controls():
	var controls_container = HBoxContainer.new()
	ui_container.add_child(controls_container)
	
	# Play/Pause button
	var play_button = create_button("Play", _on_play_pressed)
	controls_container.add_child(play_button)
	
	# Stop button
	var stop_button = create_button("Stop", _on_stop_pressed)
	controls_container.add_child(stop_button)
	
	# Loop toggle
	var loop_button = create_button("Loop: OFF", _on_loop_pressed)
	controls_container.add_child(loop_button)

func create_position_controls():
	# X Position control
	var x_container = create_labeled_slider("X Position", -200.0, 200.0, 0.0, _on_x_position_changed)
	ui_container.add_child(x_container)
	
	# Y Position control
	var y_container = create_labeled_slider("Y Position", -150.0, 150.0, 0.0, _on_y_position_changed)
	ui_container.add_child(y_container)
	
	# Distance control
	var distance_container = create_labeled_slider("Max Distance", 100.0, 500.0, 300.0, _on_distance_changed)
	ui_container.add_child(distance_container)
	
	# Attenuation control
	var attenuation_container = create_labeled_slider("Attenuation", 0.1, 3.0, 1.0, _on_attenuation_changed)
	ui_container.add_child(attenuation_container)
	
	# Panning Strength control
	var panning_container = create_labeled_slider("Panning Strength", 0.0, 2.0, 1.0, _on_panning_changed)
	ui_container.add_child(panning_container)

func create_visualization():
	var viz_label = Label.new()
	viz_label.text = "\nVisualization:"
	ui_container.add_child(viz_label)
	
	# Create a simple text-based visualization
	var position_display = Label.new()
	position_display.name = "PositionDisplay"
	position_display.text = "🎵 Sound Source: (0, 0)\n👂 Listener: (0, 0)\n📏 Distance: 0"
	ui_container.add_child(position_display)

func show_audio_info():
	var info_label = Label.new()
	var length = wav_stream.get_length() if wav_stream else 0.0
	info_label.text = "Audio Info:\n• Format: WAV\n• Length: %.2f seconds\n• Type: Positional 2D Audio\n• Playback Type: Sample (Low Latency)" % length
	ui_container.add_child(info_label)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "\nInstructions:\n• Move the sound source using X/Y sliders\n• Adjust max distance to control audio falloff\n• Change attenuation for distance-based volume\n• Modify panning strength for stereo effect\n• Use keyboard: 1=Play, 2=Stop, 3=Loop"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(instructions)

func update_visualization():
	var display = ui_container.get_node("PositionDisplay")
	if display:
		var distance = source_position.length()
		display.text = "🎵 Sound Source: (%.0f, %.0f)\n👂 Listener: (0, 0)\n📏 Distance: %.1f" % [source_position.x, source_position.y, distance]

func show_error(message: String):
	var error_label = Label.new()
	error_label.text = "Error: " + message
	error_label.add_theme_color_override("font_color", Color.RED)
	ui_container.add_child(error_label)

func _on_play_pressed():
	if not is_playing and audio_player:
		audio_player.play()
		is_playing = true
		print("Positional audio started playing at: ", source_position)

func _on_stop_pressed():
	if audio_player:
		audio_player.stop()
		is_playing = false
		print("Positional audio stopped")

func _on_loop_pressed():
	if audio_player and audio_player.stream:
		var stream = audio_player.stream as AudioStreamWAV
		if stream:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if stream.loop_mode == AudioStreamWAV.LOOP_DISABLED else AudioStreamWAV.LOOP_DISABLED
			var loop_text = "Loop: ON" if stream.loop_mode != AudioStreamWAV.LOOP_DISABLED else "Loop: OFF"
			# Update button text
			for child in ui_container.get_children():
				if child is HBoxContainer:
					for button in child.get_children():
						if button is Button and button.text.begins_with("Loop:"):
							button.text = loop_text
							break

func _on_x_position_changed(value: float):
	source_position.x = value
	if audio_player:
		audio_player.position = source_position
	update_visualization()

func _on_y_position_changed(value: float):
	source_position.y = value
	if audio_player:
		audio_player.position = source_position
	update_visualization()

func _on_distance_changed(value: float):
	if audio_player:
		audio_player.max_distance = value

func _on_attenuation_changed(value: float):
	if audio_player:
		audio_player.attenuation = value

func _on_panning_changed(value: float):
	if audio_player:
		audio_player.panning_strength = value

func _input(event):
	if event.is_action_pressed("ui_1"):  # 1 key
		_on_play_pressed()
	elif event.is_action_pressed("ui_2"):  # 2 key
		_on_stop_pressed()
	elif event.is_action_pressed("ui_3"):  # 3 key
		_on_loop_pressed()
