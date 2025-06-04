extends TutorialBase
class_name AudioDemoPlayer

# Base class for all audio demo players
# Provides audio-specific functionality for audio tutorials

func get_demo_category() -> String:
	return "audio"

func create_audio_player(stream: AudioStream) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	# Use Sample playback mode for low latency on web
	player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
	add_child(player)
	return player

func load_audio_resource(path: String) -> AudioStream:
	var resource = load(path)
	if resource and resource is AudioStream:
		return resource
	else:
		print("Failed to load audio resource: ", path)
		return null
