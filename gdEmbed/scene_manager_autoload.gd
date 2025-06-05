extends Node

# Global scene manager autoload
# Automatically discovers and manages all tutorial categories and scenes
# Now uses pure path-based discovery without requiring configuration

var available_categories: Dictionary = {}

func _ready():
	# Discover all available categories and scenes
	discover_categories()
	print("🔍 SceneManager autoload discovered categories: ", available_categories.keys())

func discover_categories():
	available_categories.clear()
	var scenes_path = "res://scenes/"
	
	print("🔍 Starting category discovery in: " + scenes_path)
	
	# Get all directories in the scenes folder
	var dir = DirAccess.open(scenes_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		print("📁 Files/directories found in scenes:")
		var found_any = false
		
		while file_name != "":
			print("  - " + file_name + " (is_dir: " + str(dir.current_is_dir()) + ")")
			
			if dir.current_is_dir() and not file_name.begins_with("."):
				found_any = true
				print("🔍 Processing category directory: " + file_name)
				
				# Discover any directory that contains scene files
				var category_data = discover_category_scenes(file_name)
				if category_data.scenes.size() > 0:
					available_categories[file_name] = category_data
					print("✅ Discovered category: " + file_name + " with " + str(category_data.scenes.size()) + " scenes")
				else:
					print("⚠️ Category " + file_name + " has no valid scenes")
			elif not dir.current_is_dir():
				print("📄 Skipping file: " + file_name)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
		
		if not found_any:
			print("⚠️ No directories found in " + scenes_path)
			
			# Add fallback test category if no real categories found
			_create_fallback_categories()
	else:
		print("❌ Could not open directory: " + scenes_path)
		_create_fallback_categories()
	
	print("🔍 Final categories discovered: " + str(available_categories.keys().size()))
	for cat_key in available_categories.keys():
		print("  - " + cat_key + ": " + str(available_categories[cat_key].scenes.size()) + " scenes")

func _create_fallback_categories():
	print("🔧 Creating fallback categories for testing...")
	
	# Create a test audio category since we know basic_audio_demo.gd exists
	var test_audio_category = {
		"title": "Audio Systems",
		"description": "Audio playback and visualization demos",
		"icon": "🔊",
		"scenes": {}
	}
	
	# Check if the basic audio demo actually exists
	var demo_paths = [
		"res://scenes/audio/basic_audio/basic_audio_demo.tscn",
		"res://gdEmbed/scenes/audio/basic_audio/basic_audio_demo.tscn",
		"res://basic_audio_demo.tscn"
	]
	
	for demo_path in demo_paths:
		if ResourceLoader.exists(demo_path):
			print("✅ Found basic audio demo at: " + demo_path)
			test_audio_category.scenes["basic_audio"] = {
				"title": "Professional Audio Player",
				"description": "Professional sample player with waveform visualization",
				"path": demo_path
			}
			break
	
	# If we found any scenes, add the category
	if test_audio_category.scenes.size() > 0:
		available_categories["audio"] = test_audio_category
		print("✅ Added fallback audio category with " + str(test_audio_category.scenes.size()) + " scenes")
	else:
		print("⚠️ No demo scenes found in any expected location")
		print("Expected paths:")
		for path in demo_paths:
			print("  - " + path + " (exists: " + str(ResourceLoader.exists(path)) + ")")

func discover_scene(category_name: String, scene_name: String) -> Dictionary:
	var scene_path = "res://scenes/" + category_name + "/" + scene_name + "/"
	
	print("🎯 Discovering scene: " + category_name + "/" + scene_name)
	print("   Looking in: " + scene_path)
	print("   Category folder: " + category_name)
	
	# Check if the directory exists first
	var dir = DirAccess.open(scene_path)
	if not dir:
		print("❌ Directory not found: " + scene_path)
		return {}
	
	# Try multiple possible scene file naming patterns
	var possible_scene_files = [
		scene_path + scene_name + ".tscn",                    # exact match
		scene_path + scene_name + "_demo.tscn",              # with _demo suffix
		scene_path + scene_name + "_scene.tscn",             # with _scene suffix
		scene_path + scene_name.replace("_", "") + ".tscn",  # without underscores
		scene_path + "demo.tscn",                            # generic demo.tscn
		scene_path + "main.tscn",                            # generic main.tscn
		scene_path + "scene.tscn"                            # generic scene.tscn
	]
	
	# Also check for renamed patterns like advance_audio_player -> advance_audio_demo
	if scene_name.ends_with("_player"):
		var demo_name = scene_name.replace("_player", "_demo")
		possible_scene_files.append(scene_path + demo_name + ".tscn")
	
	# Find any .tscn files in the directory if standard patterns fail
	print("📁 Scanning directory for .tscn files...")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		print("   Found file: " + file_name)
		if file_name.ends_with(".tscn"):
			var full_path = scene_path + file_name
			if not possible_scene_files.has(full_path):
				possible_scene_files.append(full_path)
				print("   Added .tscn file: " + full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	print("🔍 Checking possible scene files:")
	var scene_file_path = ""
	for possible_path in possible_scene_files:
		print("   Checking: " + possible_path + " (exists: " + str(ResourceLoader.exists(possible_path)) + ")")
		if ResourceLoader.exists(possible_path):
			scene_file_path = possible_path
			break
	
	if scene_file_path == "":
		print("⚠️ Scene file not found for: " + scene_name + " in " + category_name)
		print("   Searched paths:")
		for path in possible_scene_files:
			print("     - " + path)
		return {}
	
	print("✅ Found scene: " + scene_file_path)
	print("📁 Scene belongs to category: " + category_name)
	
	# Extract metadata from README - prioritize markdown title
	var readme_metadata = extract_metadata_from_readme(scene_path)
	
	# Use markdown title first, then auto-generated as fallback (no more CategoryConfig)
	var title = readme_metadata.get("title", _generate_title_from_path(scene_name))
	
	# For description, always use auto-generated for consistency
	var description = _generate_simple_description_from_path(scene_name)
	
	print("📄 Scene metadata for " + scene_name + ":")
	print("  - Title: " + title)
	print("  - Description: " + description)
	print("  - Category: " + category_name)
	print("  - Source: " + ("README markdown title" if readme_metadata.has("title") else "auto-generated"))
	
	return {
		"path": scene_file_path,
		"title": title,
		"description": description,
		"category": category_name,  # Add explicit category mapping
		"url_safe_name": _url_safe_name(scene_name)  # Add URL-safe version for navigation
	}

# Helper function to create URL-safe names
func _url_safe_name(name: String) -> String:
	# Convert to URL-safe format (replace spaces, special chars)
	var safe_name = name.to_lower()
	safe_name = safe_name.replace(" ", "_")
	safe_name = safe_name.replace("-", "_")
	
	# Remove any characters that might cause URL issues
	var allowed_chars = "abcdefghijklmnopqrstuvwxyz0123456789_"
	var result = ""
	for i in range(safe_name.length()):
		var char = safe_name[i]
		if allowed_chars.find(char) != -1:
			result += char
	
	return result

func extract_metadata_from_readme(scene_path: String) -> Dictionary:
	var readme_path = scene_path + "README.md"
	var metadata = {}
	
	if FileAccess.file_exists(readme_path):
		var file = FileAccess.open(readme_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			# Parse markdown title first - this is now the PRIMARY source
			var markdown_title = parse_markdown_title(content)
			if markdown_title.size() > 0:
				metadata = markdown_title
				print("📋 Found markdown title in " + readme_path)
			else:
				# Fallback to frontmatter if no markdown title
				metadata = parse_frontmatter(content)
				if metadata.size() > 0:
					print("📝 Found frontmatter metadata in " + readme_path)
				else:
					print("⚠️ No title found in " + readme_path)
	else:
		print("📄 No README.md found at " + readme_path)
	
	return metadata

func parse_markdown_title(content: String) -> Dictionary:
	var metadata = {}
	
	# Extract title from first # heading
	var lines = content.split("\n")
	
	for line in lines:
		var trimmed_line = line.strip_edges()
		# Look for first level 1 heading (starts with # but not ##)
		if trimmed_line.begins_with("# ") and not trimmed_line.begins_with("## "):
			# Extract title text after "# "
			var title = trimmed_line.substr(2).strip_edges()
			if title.length() > 0:
				metadata["title"] = title
				print("📋 Found markdown title: " + title)
				break
	
	return metadata

func parse_frontmatter(content: String) -> Dictionary:
	var metadata = {}
	
	# Check if content starts with frontmatter (---)
	if not content.begins_with("---"):
		return metadata
	
	# Find the closing --- 
	var lines = content.split("\n")
	var frontmatter_end = -1
	
	for i in range(1, lines.size()):
		if lines[i].strip_edges() == "---":
			frontmatter_end = i
			break
	
	if frontmatter_end == -1:
		return metadata
	
	print("📋 Parsing frontmatter from lines 1 to " + str(frontmatter_end))
	
	# Parse YAML-like frontmatter
	for i in range(1, frontmatter_end):
		var line = lines[i].strip_edges()
		if line.length() == 0 or line.begins_with("#"):
			continue
			
		var colon_pos = line.find(":")
		if colon_pos > 0:
			var key = line.substr(0, colon_pos).strip_edges()
			var value = line.substr(colon_pos + 1).strip_edges()
			
			# Remove quotes if present
			if value.begins_with('"') and value.ends_with('"'):
				value = value.substr(1, value.length() - 2)
			elif value.begins_with("'") and value.ends_with("'"):
				value = value.substr(1, value.length() - 2)
			
			metadata[key] = value
			print("  - " + key + ": " + value)
	
	return metadata

func parse_markdown_metadata(content: String) -> Dictionary:
	var metadata = {}
	
	# Extract title from first # heading
	var title_regex = RegEx.new()
	title_regex.compile("^#\\s+(.+)$")
	var lines = content.split("\n")
	
	for line in lines:
		var title_result = title_regex.search(line)
		if title_result:
			metadata["title"] = title_result.get_string(1).strip_edges()
			break
	
	# Extract description from Overview or first paragraph after title
	var overview_regex = RegEx.new()
	overview_regex.compile("## Overview\\s*\\n\\s*(.+?)(?=\\n\\n|##|$)")
	var overview_result = overview_regex.search(content)
	
	if overview_result:
		var desc_text = overview_result.get_string(1).strip_edges()
		# Clean up markdown and keep it concise
		desc_text = desc_text.replace("This demo demonstrates:", "").strip_edges()
		desc_text = desc_text.split("\n")[0].strip_edges()  # Take first line only
		if desc_text.length() > 80:
			desc_text = desc_text.substr(0, 77) + "..."
		metadata["description"] = desc_text
	
	return metadata

func _generate_title_from_path(path_name: String) -> String:
	# Convert snake_case to Title Case
	var words = path_name.split("_")
	var title_words = []
	
	for word in words:
		if word.length() > 0:
			# Capitalize first letter and make rest lowercase
			var capitalized = word[0].to_upper() + word.substr(1).to_lower()
			title_words.append(capitalized)
	
	var title = " ".join(title_words)
	
	# Add "Demo" suffix if it doesn't already contain demo-related words
	if not (title.to_lower().contains("demo") or title.to_lower().contains("example") or title.to_lower().contains("tutorial")):
		title += " Demo"
	
	return title

func _generate_description_from_path(path_name: String) -> String:
	# Generate description based on path patterns
	var base_desc = "Interactive " + _generate_title_from_path(path_name).to_lower().replace(" demo", "")
	
	# Add specific context based on path patterns
	if path_name.contains("audio"):
		return base_desc + " with sound and music features"
	elif path_name.contains("physics"):
		return base_desc + " with physics simulation"
	elif path_name.contains("input"):
		return base_desc + " for input handling"
	elif path_name.contains("movement"):
		return base_desc + " for character movement"
	elif path_name.contains("animation"):
		return base_desc + " with animation techniques"
	elif path_name.contains("ui") or path_name.contains("interface"):
		return base_desc + " for user interface"
	elif path_name.contains("network"):
		return base_desc + " for networking features"
	elif path_name.contains("shader"):
		return base_desc + " with visual effects"
	else:
		return base_desc + " demonstration"

func _generate_simple_description_from_path(path_name: String) -> String:
	# Generate very simple description - just the demo name
	var title = _generate_title_from_path(path_name).replace(" Demo", "")
	return title + " demonstration"

func _generate_icon_from_path(path_name: String) -> String:
	# Generate appropriate icons based on path patterns
	if path_name.contains("audio") or path_name.contains("sound") or path_name.contains("music"):
		return "🔊"
	elif path_name.contains("physics"):
		return "⚡"
	elif path_name.contains("input") or path_name.contains("control"):
		return "🎮"
	elif path_name.contains("movement") or path_name.contains("player"):
		return "🏃"
	elif path_name.contains("animation") or path_name.contains("tween"):
		return "🎬"
	elif path_name.contains("ui") or path_name.contains("interface"):
		return "🖱️"
	elif path_name.contains("network") or path_name.contains("multiplayer"):
		return "🌐"
	elif path_name.contains("shader") or path_name.contains("effect"):
		return "✨"
	elif path_name.contains("3d"):
		return "🎯"
	elif path_name.contains("2d"):
		return "⚽"
	else:
		return "🎮"

# Helper function to get the first demo in a category (for navigation)
func get_first_demo_in_category(category: String) -> String:
	if available_categories.has(category) and available_categories[category].scenes.size() > 0:
		return available_categories[category].scenes.keys()[0]
	return ""

# Validate if a scene exists
func is_valid_scene(category: String, scene: String) -> bool:
	return available_categories.has(category) and available_categories[category].scenes.has(scene)

func discover_category_scenes(category_name: String) -> Dictionary:
	# Try to get metadata from category README.md first
	var category_readme_path = "res://scenes/" + category_name + "/README.md"
	var category_metadata = {}
	
	if FileAccess.file_exists(category_readme_path):
		var file = FileAccess.open(category_readme_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			# Use markdown title as primary source, fallback to frontmatter
			category_metadata = parse_markdown_title(content)
			if category_metadata.size() == 0:
				category_metadata = parse_frontmatter(content)
	
	# Create category data with markdown title as primary source (no more CategoryConfig)
	var category_data = {
		"title": category_metadata.get("title", _generate_title_from_path(category_name)),
		"description": category_metadata.get("description", _generate_description_from_path(category_name)),
		"icon": category_metadata.get("icon", _generate_icon_from_path(category_name)),
		"scenes": {}
	}
	
	print("📁 Category metadata for " + category_name + ":")
	print("  - Title: " + category_data.title)
	print("  - Description: " + category_data.description)
	print("  - Icon: " + category_data.icon)
	print("  - Source: " + ("README markdown title" if category_metadata.has("title") else "auto-generated"))
	
	var category_path = "res://scenes/" + category_name + "/"
	var dir = DirAccess.open(category_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				# Check if this directory contains a scene file
				var scene_data = discover_scene(category_name, file_name)
				if scene_data:
					category_data.scenes[file_name] = scene_data
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return category_data
