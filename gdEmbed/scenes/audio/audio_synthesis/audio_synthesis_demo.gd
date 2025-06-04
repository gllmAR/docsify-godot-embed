extends AudioDemoPlayer

# Audio Synthesis Demo - Basic procedural audio generation
# Demonstrates AudioStreamGenerator and simple waveform synthesis
# Note: Limited functionality on web due to Sample playback mode restrictions

var audio_player: AudioStreamPlayer
var audio_generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var is_playing := false
var frequency := 440.0
var amplitude := 0.3
var wave_type := 0  # 0=Sine, 1=Square, 2=Sawtooth, 3=Triangle
var phase := 0.0

func get_demo_title() -> String:
	return "Audio Synthesis - Basic Waveform Generation"

func get_demo_description() -> String:
	return "Explore basic audio synthesis with AudioStreamGenerator. Generate sine, square, sawtooth, and triangle waves. Note: Limited functionality on web platforms due to Sample playback mode constraints."

func setup_demo_specific():
	setup_audio_generator()
	create_playback_controls()
	create_synthesis_controls()
	show_audio_info()

func setup_audio_generator():
	# Create AudioStreamGenerator
	audio_generator = AudioStreamGenerator.new()
	audio_generator.sample_rate = 44100
	audio_generator.buffer_length = 0.1  # 100ms buffer
	
	# Create AudioStreamPlayer
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = audio_generator
	# Note: Sample playback mode may not work well with procedural audio
	audio_player.playback_type = AudioServer.PLAYBACK_TYPE_DEFAULT
	audio_player.volume_db = -10.0
	
	add_child(audio_player)

func create_playback_controls():
	var controls_container = HBoxContainer.new()
	ui_container.add_child(controls_container)
	
	# Play button
	var play_button = create_button("Play", _on_play_pressed)
	controls_container.add_child(play_button)
	
	# Stop button
	var stop_button = create_button("Stop", _on_stop_pressed)
	controls_container.add_child(stop_button)
	
	# Wave type selection
	var wave_container = HBoxContainer.new()
	controls_container.add_child(wave_container)
	
	var wave_label = Label.new()
	wave_label.text = "Wave:"
	wave_container.add_child(wave_label)
	
	var wave_options = ["Sine", "Square", "Sawtooth", "Triangle"]
	for i in range(wave_options.size()):
		var wave_button = create_button(wave_options[i], func(): _on_wave_type_changed(i))
		wave_container.add_child(wave_button)

func create_synthesis_controls():
	# Frequency control
	var freq_container = create_labeled_slider("Frequency (Hz)", 220.0, 880.0, 440.0, _on_frequency_changed)
	ui_container.add_child(freq_container)
	
	# Amplitude control
	var amp_container = create_labeled_slider("Amplitude", 0.0, 1.0, 0.3, _on_amplitude_changed)
	ui_container.add_child(amp_container)
	
	# Volume control
	var volume_container = create_labeled_slider("Volume (dB)", -30.0, 0.0, -10.0, _on_volume_changed)
	ui_container.add_child(volume_container)

func show_audio_info():
	var info_label = Label.new()
	info_label.text = "Audio Synthesis Info:\n• Sample Rate: 44.1kHz\n• Buffer Length: 100ms\n• Wave Types: Sine, Square, Sawtooth, Triangle\n• Real-time procedural generation"
	ui_container.add_child(info_label)
	
	# Add web platform warning
	var warning_label = Label.new()
	warning_label.text = "\n⚠️ Web Platform Limitations:\n• AudioStreamGenerator may have reduced functionality\n• Real-time synthesis may not work optimally\n• Consider pre-generated samples for web deployment"
	warning_label.add_theme_color_override("font_color", Color.ORANGE)
	warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(warning_label)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "\nInstructions:\n• Select wave type using buttons\n• Adjust frequency (pitch) and amplitude (volume)\n• Use Play/Stop to control synthesis\n• Experiment with different waveforms\n• Use keyboard: 1=Play, 2=Stop, 3=Change Wave"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(instructions)

func generate_audio_samples():
	if not playback:
		return
	
	var sample_rate = audio_generator.sample_rate
	var frames_to_fill = playback.get_frames_available()
	
	if frames_to_fill == 0:
		return
	
	var samples = PackedFloat32Array()
	samples.resize(frames_to_fill * 2)  # Stereo
	
	for i in range(frames_to_fill):
		var sample_value = generate_sample()
		samples[i * 2] = sample_value      # Left channel
		samples[i * 2 + 1] = sample_value  # Right channel
		
		# Update phase
		phase += (frequency * 2.0 * PI) / sample_rate
		if phase > 2.0 * PI:
			phase -= 2.0 * PI
	
	playback.push_buffer(samples)

func generate_sample() -> float:
	var sample: float
	
	match wave_type:
		0:  # Sine wave
			sample = sin(phase)
		1:  # Square wave
			sample = 1.0 if sin(phase) > 0.0 else -1.0
		2:  # Sawtooth wave
			sample = (phase / PI) - 1.0
		3:  # Triangle wave
			var normalized_phase = phase / (2.0 * PI)
			if normalized_phase < 0.5:
				sample = (normalized_phase * 4.0) - 1.0
			else:
				sample = 3.0 - (normalized_phase * 4.0)
		_:
			sample = 0.0
	
	return sample * amplitude

func _on_play_pressed():
	if not is_playing:
		audio_player.play()
		playback = audio_player.get_stream_playback()
		is_playing = true
		print("Audio synthesis started - Frequency: %.1fHz, Wave: %s" % [frequency, get_wave_name()])

func _on_stop_pressed():
	if is_playing:
		audio_player.stop()
		playback = null
		is_playing = false
		phase = 0.0
		print("Audio synthesis stopped")

func _on_wave_type_changed(new_type: int):
	wave_type = new_type
	print("Wave type changed to: ", get_wave_name())

func _on_frequency_changed(value: float):
	frequency = value

func _on_amplitude_changed(value: float):
	amplitude = value

func _on_volume_changed(value: float):
	if audio_player:
		audio_player.volume_db = value

func get_wave_name() -> String:
	match wave_type:
		0: return "Sine"
		1: return "Square"
		2: return "Sawtooth"
		3: return "Triangle"
		_: return "Unknown"

func _process(_delta):
	if is_playing and playback:
		generate_audio_samples()

func _input(event):
	if event.is_action_pressed("ui_1"):  # 1 key
		_on_play_pressed()
	elif event.is_action_pressed("ui_2"):  # 2 key
		_on_stop_pressed()
	elif event.is_action_pressed("ui_3"):  # 3 key
		_on_wave_type_changed((wave_type + 1) % 4)
