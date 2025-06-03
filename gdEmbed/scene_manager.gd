extends Node2D

var available_scenes = {
	"movement": "res://scenes/movement/movement.tscn",
	"animation": "res://scenes/animation/animation.tscn", 
	"physics": "res://scenes/physics/physics.tscn",
	"input": "res://scenes/input/input.tscn"
}

func _ready():
	var scene_name = _parse_scene_parameter()
	_load_scene(scene_name)

func _parse_scene_parameter() -> String:
	var default_scene = "movement"
	
	if OS.has_feature("web"):
		# Simple and reliable URL parameter parsing
		var scene_result = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('scene')")
		print("🎮 Scene parameter from URL: ", scene_result)
		
		if scene_result and scene_result != "" and available_scenes.has(scene_result):
			print("✅ Loading scene: ", scene_result)
			return scene_result
		else:
			print("⚠️ Using default scene: ", default_scene)
	
	return default_scene

func _load_scene(scene_name: String):
	if available_scenes.has(scene_name):
		var scene_path = available_scenes[scene_name]
		var scene = load(scene_path)
		if scene:
			var instance = scene.instantiate()
			add_child(instance)
			print("Loaded scene: " + scene_name)
		else:
			print("Failed to load scene: " + scene_name)
	else:
		print("Unknown scene: " + scene_name)
