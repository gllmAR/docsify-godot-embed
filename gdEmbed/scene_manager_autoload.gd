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
	
	# For web exports, we need to handle directory access differently
	if OS.has_feature("web"):
		# In web exports, we can't use DirAccess.open() reliably
		# Instead, try to load known scene patterns
		var known_scenes = _discover_scenes_web_fallback(category_name)
		for scene_data in known_scenes:
			category_data.scenes[scene_data.scene_key] = scene_data.scene_info
	else:
		# Desktop/editor version - use directory scanning
		var dir = DirAccess.open(category_path)
		if dir:
			# First, collect scene directories
			var scene_directories = []
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				if dir.current_is_dir() and not file_name.begins_with("."):
					scene_directories.append(file_name)
				file_name = dir.get_next()
			
			dir.list_dir_end()
			
			# Also scan for direct .tscn files in the category root
			var direct_scenes = []
			dir.list_dir_begin()
			file_name = dir.get_next()
			
			while file_name != "":
				if file_name.ends_with(".tscn") and not dir.current_is_dir():
					direct_scenes.append(file_name)
				file_name = dir.get_next()
			
			dir.list_dir_end()
			
			# Process direct .tscn files in category root
			for scene_file in direct_scenes:
				var scene_name = scene_file.get_basename()  # Remove .tscn extension
				var full_path = category_path + scene_file
				if ResourceLoader.exists(full_path):
					category_data.scenes[scene_name] = {
						"path": full_path,
						"title": _generate_title(scene_name),
						"description": _generate_description(scene_name),
						"category": category_name
					}
					print("✅ Found direct scene: " + full_path)
			
			# Sort and process scene directories
			scene_directories.sort()
			for scene_dir in scene_directories:
				var scenes_in_dir = discover_scenes_in_directory(category_name, scene_dir)
				for scene_data in scenes_in_dir:
					category_data.scenes[scene_data.scene_key] = scene_data.scene_info
	
	return category_data

func _discover_scenes_web_fallback(category_name: String) -> Array:
	"""Fallback scene discovery for web exports using known patterns"""
	var found_scenes = []
	var category_path = "res://scenes/" + category_name + "/"
	
	# Common scene directory names to try
	var common_scene_names = [
		"basic_" + category_name,
		"advanced_" + category_name,
		"simple_" + category_name,
		category_name + "_demo",
		category_name + "_basic",
		category_name + "_advanced"
	]
	
	# Also try some generic names
	common_scene_names.append_array([
		"basic_animation", "tweening", "state_machines",
		"basic_audio", "advance_audioplayer", 
		"keyboard_input", "mouse_input", "gamepad_input",
		"basic_movement", "platformer_movement", "top_down_movement",
		"basic_physics", "collision_detection", "rigid_bodies",
		"particle_systems", "shader_effects"
	])
	
	# Try to find scenes by attempting to load common patterns
	for scene_name in common_scene_names:
		var scene_dir_path = category_path + scene_name + "/"
		
		# Common scene file patterns
		var scene_file_patterns = [
			scene_name + ".tscn",
			scene_name + "_demo.tscn",
			"demo.tscn",
			"main.tscn"
		]
		
		for pattern in scene_file_patterns:
			var full_path = scene_dir_path + pattern
			if ResourceLoader.exists(full_path):
				var scene_key = scene_name
				var title = _generate_title(scene_name)
				
				found_scenes.append({
					"scene_key": scene_key,
					"scene_info": {
						"path": full_path,
						"title": title,
						"description": _generate_description(scene_key),
						"category": category_name
					}
				})
				
				print("✅ Found web scene: " + full_path + " (key: " + scene_key + ")")
				break  # Found one, move to next scene_name
	
	return found_scenes

func discover_scenes_in_directory(category_name: String, scene_dir: String) -> Array:
	var scene_path = "res://scenes/" + category_name + "/" + scene_dir + "/"
	var found_scenes = []
	
	# For web exports, use fallback method
	if OS.has_feature("web"):
		# Try common scene file patterns for this specific directory
		var scene_file_patterns = [
			scene_dir + ".tscn",
			scene_dir + "_demo.tscn",
			"demo.tscn",
			"main.tscn"
		]
		
		for pattern in scene_file_patterns:
			var full_path = scene_path + pattern
			if ResourceLoader.exists(full_path):
				var scene_key = scene_dir
				var title = _generate_title(scene_dir)
				
				found_scenes.append({
					"scene_key": scene_key,
					"scene_info": {
						"path": full_path,
						"title": title,
						"description": _generate_description(scene_key),
						"category": category_name
					}
				})
				
				print("✅ Found web scene in directory: " + full_path + " (key: " + scene_key + ")")
				break  # Found one, that's enough for this directory
		
		return found_scenes
	
	# Desktop/editor version - use directory scanning
	var dir = DirAccess.open(scene_path)
	if not dir:
		return found_scenes
	
	# Find ALL .tscn files in this directory
	var scene_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var full_path = scene_path + file_name
			if ResourceLoader.exists(full_path):
				scene_files.append({
					"file": file_name,
					"path": full_path
				})
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# Sort scene files alphabetically
	scene_files.sort_custom(func(a, b): return a.file < b.file)
	
	# Process each scene file
	for i in range(scene_files.size()):
		var scene_file_data = scene_files[i]
		var scene_file = scene_file_data.file
		var full_path = scene_file_data.path
		
		# Generate unique scene key
		var scene_key = scene_dir
		if scene_files.size() > 1:
			# If multiple scenes in directory, append file identifier
			var file_name_without_ext = scene_file.get_basename()
			if file_name_without_ext != scene_dir:
				scene_key = scene_dir + "_" + file_name_without_ext
			else:
				# Use index for identical names
				if i > 0:
					scene_key = scene_dir + "_" + str(i + 1)
		
		# Generate title
		var title = _generate_title(scene_dir)
		if scene_files.size() > 1:
			var file_title = _generate_title(scene_file.get_basename())
			if file_title != title:
				title = title + " - " + file_title
			elif i > 0:
				title = title + " " + str(i + 1)
		
		found_scenes.append({
			"scene_key": scene_key,
			"scene_info": {
				"path": full_path,
				"title": title,
				"description": _generate_description(scene_key),
				"category": category_name
			}
		})
		
		print("✅ Found scene: " + full_path + " (key: " + scene_key + ")")
	
	return found_scenes

func find_scene_file(scene_path: String, scene_name: String) -> String:
	var dir = DirAccess.open(scene_path)
	if not dir:
		return ""
	
	# Find the first .tscn file (kept for backward compatibility)
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
	# Remove the automatic "Demo" suffix - let scenes define their own titles
	return title

func _generate_description(name: String) -> String:
	return _generate_title(name) + " scene"

func _generate_icon(name: String) -> String:
	# Make icon detection more flexible - check for keywords anywhere in the name
	var lower_name = name.to_lower()
	if "audio" in lower_name or "sound" in lower_name: return "🔊"
	elif "physics" in lower_name or "collision" in lower_name or "rigid" in lower_name: return "⚡"
	elif "input" in lower_name or "keyboard" in lower_name or "mouse" in lower_name or "gamepad" in lower_name: return "🎮"
	elif "movement" in lower_name or "move" in lower_name or "platformer" in lower_name: return "🏃"
	elif "animation" in lower_name or "tween" in lower_name or "state" in lower_name: return "🎬"
	elif "visual" in lower_name or "effect" in lower_name or "particle" in lower_name or "shader" in lower_name: return "✨"
	elif "ui" in lower_name or "interface" in lower_name or "menu" in lower_name: return "📱"
	elif "network" in lower_name or "multiplayer" in lower_name: return "🌐"
	elif "file" in lower_name or "save" in lower_name or "load" in lower_name: return "💾"
	else: return "🎯"

func is_valid_scene(category: String, scene: String) -> bool:
	return available_categories.has(category) and available_categories[category].scenes.has(scene)
