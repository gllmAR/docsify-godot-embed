extends Node

# Lean scene discovery autoload - focused on finding available scenes
var available_categories: Dictionary = {}

func _ready():
	discover_categories()
	print("🔍 SceneManager autoload discovered categories: ", available_categories.keys())

func discover_categories():
	available_categories.clear()
	var scenes_path = "res://scenes/"
	
	print("🔍 Starting category discovery in: " + scenes_path)
	
	var dir = DirAccess.open(scenes_path)
	if not dir:
		print("❌ Could not open directory: " + scenes_path)
		return
	
	# Collect directories first, then sort
	var category_names = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			category_names.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Sort alphabetically
	category_names.sort()
	
	# Process sorted categories
	for category_name in category_names:
		var category_data = discover_category_scenes(category_name)
		if category_data.scenes.size() > 0:
			available_categories[category_name] = category_data
			print("✅ Discovered category: " + category_name + " with " + str(category_data.scenes.size()) + " scenes")
	
	print("🔍 Final categories discovered: " + str(available_categories.keys().size()))

func discover_category_scenes(category_name: String) -> Dictionary:
	var category_data = {
		"title": _generate_title(category_name),
		"description": _generate_description(category_name),
		"icon": _generate_icon(category_name),
		"scenes": {}
	}
	
	var category_path = "res://scenes/" + category_name + "/"
	var dir = DirAccess.open(category_path)
	
	if dir:
		# Collect scene directories first, then sort
		var scene_names = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				scene_names.append(file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
		
		# Sort alphabetically
		scene_names.sort()
		
		# Process sorted scenes
		for scene_name in scene_names:
			var scene_data = discover_scene(category_name, scene_name)
			if scene_data:
				category_data.scenes[scene_name] = scene_data
	
	return category_data

func discover_scene(category_name: String, scene_name: String) -> Dictionary:
	var scene_path = "res://scenes/" + category_name + "/" + scene_name + "/"
	
	# Find .tscn file in directory
	var scene_file = find_scene_file(scene_path, scene_name)
	if scene_file == "":
		return {}
	
	print("✅ Found scene: " + scene_file)
	
	return {
		"path": scene_file,
		"title": _generate_title(scene_name),
		"description": _generate_description(scene_name),
		"category": category_name
	}

func find_scene_file(scene_path: String, scene_name: String) -> String:
	var dir = DirAccess.open(scene_path)
	if not dir:
		return ""
	
	# Common scene file patterns
	var patterns = [
		scene_name + ".tscn",
		scene_name + "_demo.tscn",
		"demo.tscn",
		"main.tscn"
	]
	
	# Check patterns first
	for pattern in patterns:
		var full_path = scene_path + pattern
		if ResourceLoader.exists(full_path):
			return full_path
	
	# Scan for any .tscn file
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var full_path = scene_path + file_name
			if ResourceLoader.exists(full_path):
				dir.list_dir_end()
				return full_path
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return ""

func _generate_title(name: String) -> String:
	var words = name.split("_")
	var title_words = []
	
	for word in words:
		if word.length() > 0:
			title_words.append(word[0].to_upper() + word.substr(1).to_lower())
	
	var title = " ".join(title_words)
	if not title.to_lower().contains("demo"):
		title += " Demo"
	
	return title

func _generate_description(name: String) -> String:
	return _generate_title(name).replace(" Demo", "") + " demonstration"

func _generate_icon(name: String) -> String:
	if name.contains("audio"): return "🔊"
	elif name.contains("physics"): return "⚡"
	elif name.contains("input"): return "🎮"
	elif name.contains("movement"): return "🏃"
	elif name.contains("animation"): return "🎬"
	elif name.contains("visual"): return "✨"
	else: return "🎯"

func is_valid_scene(category: String, scene: String) -> bool:
	return available_categories.has(category) and available_categories[category].scenes.has(scene)
