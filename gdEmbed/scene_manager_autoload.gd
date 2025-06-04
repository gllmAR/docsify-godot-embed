extends Node

# Global scene manager autoload
# Automatically discovers and manages all tutorial categories and scenes

# Import the configuration
const CategoryConfig = preload("res://category_config.gd")

var available_categories: Dictionary = {}

func _ready():
	# Discover all available categories and scenes
	discover_categories()
	print("🔍 SceneManager autoload discovered categories: ", available_categories.keys())

func discover_categories():
	available_categories.clear()
	var scenes_path = "res://scenes/"
	
	# Get all directories in the scenes folder
	var dir = DirAccess.open(scenes_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				# Skip the tutorial_base and other non-category folders
				if file_name in CategoryConfig.CATEGORY_METADATA:
					var category_data = discover_category_scenes(file_name)
					if category_data.scenes.size() > 0:
						available_categories[file_name] = category_data
			file_name = dir.get_next()
		
		dir.list_dir_end()

func discover_category_scenes(category_name: String) -> Dictionary:
	# Try to get metadata from category README.md first
	var category_readme_path = "res://scenes/" + category_name + "/README.md"
	var category_metadata = {}
	
	if FileAccess.file_exists(category_readme_path):
		var file = FileAccess.open(category_readme_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			category_metadata = parse_frontmatter(content)
			if not category_metadata:
				category_metadata = parse_markdown_metadata(content)
	
	# Fallback to hardcoded metadata if no README or no frontmatter
	var fallback_metadata = CategoryConfig.CATEGORY_METADATA.get(category_name, {})
	var category_data = {
		"title": category_metadata.get("title", fallback_metadata.get("title", category_name.capitalize())),
		"description": category_metadata.get("description", fallback_metadata.get("description", "Interactive " + category_name + " demonstrations")),
		"icon": category_metadata.get("icon", fallback_metadata.get("icon", "🎯")),
		"scenes": {}
	}
	
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

func discover_scene(category_name: String, scene_name: String) -> Dictionary:
	var scene_path = "res://scenes/" + category_name + "/" + scene_name + "/"
	var scene_file_path = scene_path + scene_name + ".tscn"
	
	# Check if the scene file exists, if not try with _demo suffix
	if not ResourceLoader.exists(scene_file_path):
		scene_file_path = scene_path + scene_name + "_demo.tscn"
		if not ResourceLoader.exists(scene_file_path):
			print("⚠️ Scene file not found: " + scene_file_path)
			return {}
	
	# Get metadata from fallbacks or try to extract from README
	var scene_metadata = CategoryConfig.SCENE_METADATA_FALLBACKS.get(scene_name, {})
	var readme_metadata = extract_metadata_from_readme(scene_path)
	
	# Merge metadata (README takes precedence)
	var title = readme_metadata.get("title", scene_metadata.get("title", scene_name.replace("_", " ").capitalize()))
	var description = readme_metadata.get("description", scene_metadata.get("description", "Interactive " + scene_name.replace("_", " ") + " demonstration"))
	
	return {
		"path": scene_file_path,
		"title": title,
		"description": description
	}

func extract_metadata_from_readme(scene_path: String) -> Dictionary:
	var readme_path = scene_path + "README.md"
	var metadata = {}
	
	if FileAccess.file_exists(readme_path):
		var file = FileAccess.open(readme_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			# Parse frontmatter if it exists
			var frontmatter = parse_frontmatter(content)
			if frontmatter:
				metadata = frontmatter
			else:
				# Fallback to parsing markdown headings
				metadata = parse_markdown_metadata(content)
	
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

# Helper function to get the first demo in a category (for navigation)
func get_first_demo_in_category(category: String) -> String:
	if available_categories.has(category) and available_categories[category].scenes.size() > 0:
		return available_categories[category].scenes.keys()[0]
	return ""

# Validate if a scene exists
func is_valid_scene(category: String, scene: String) -> bool:
	return available_categories.has(category) and available_categories[category].scenes.has(scene)
