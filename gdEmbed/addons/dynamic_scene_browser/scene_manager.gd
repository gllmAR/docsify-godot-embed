extends Node2D

# Scene manager that uses the SceneManagerGlobal autoload data
var selector_ui: Control
var is_selector_active = false
var folder_states: Dictionary = {}  # Track folder expansion states

# Safety check for autoload
var scene_manager_global: Node

func _ready():
	# Safely get the autoload
	scene_manager_global = get_node_or_null("/root/SceneManagerGlobal")
	
	if not scene_manager_global:
		print("❌ SceneManagerGlobal autoload not found - plugin may be disabled")
		return
	
	print("🔍 Scene Manager starting in " + ("web" if OS.has_feature("web") else "desktop") + " mode")
	print("🔍 Available scenes: " + str(scene_manager_global.discovered_scenes.size()) + " total")
	
	if OS.has_feature("web"):
		load_scene_from_url()
	else:
		_show_scene_browser()

func load_scene_from_url():
	# Get scene parameter from URL
	var js_code = """
	(function() {
		var urlParams = new URLSearchParams(window.location.search);
		var scene = urlParams.get('scene');
		return scene || '';
	})();
	"""
	
	var scene_path = JavaScriptBridge.eval(js_code)
	
	if scene_path and scene_path != "":
		print("🔗 Scene path: " + scene_path)
		
		# Try different path formats to find the scene
		var scene_info = _find_scene_by_path(scene_path)
		
		if scene_info.size() > 0:
			print("✅ Loading scene: " + scene_info.name)
			get_tree().change_scene_to_file(scene_info.path)
		else:
			print("⚠️ Invalid scene path: " + scene_path)
			_show_scene_browser()
	else:
		print("📁 No scene specified, showing browser")
		_show_scene_browser()

func _find_scene_by_path(path: String) -> Dictionary:
	"""Try multiple strategies to find a scene by path"""
	
	if not scene_manager_global:
		print("❌ SceneManagerGlobal not available")
		return {}
	
	print("🔍 Searching for scene with path: '" + path + "'")
	
	# Strategy 1: Direct key lookup (animation_basic_animation_basic_animation)
	var direct_key = path.replace("/", "_")
	if scene_manager_global.discovered_scenes.has(direct_key):
		print("✅ Found by direct key: " + direct_key)
		return scene_manager_global.discovered_scenes[direct_key]
	
	# Strategy 2: Try with specific patterns that match our manifest structure
	var path_parts = path.split("/")
	if path_parts.size() >= 2:
		var category = path_parts[0]    # e.g., "animation"
		var folder = path_parts[1]      # e.g., "basic_animation"
		
		# Our manifest structure uses: category_folder_folder pattern
		var pattern_keys = [
			category + "_" + folder + "_" + folder,              # animation_basic_animation_basic_animation
			category + "_" + folder + "_" + folder + "_demo",    # animation_basic_animation_basic_animation_demo
			category + "_" + folder + "_demo",                   # animation_basic_animation_demo
			category + "_" + folder,                             # animation_basic_animation
			category + "_" + folder + "_" + category,            # animation_basic_animation_animation
		]
		
		for key in pattern_keys:
			if scene_manager_global.discovered_scenes.has(key):
				print("✅ Found scene with pattern key: " + key)
				return scene_manager_global.discovered_scenes[key]
	
	# Strategy 3: Search by directory match from manifest
	for scene_key in scene_manager_global.discovered_scenes.keys():
		var scene_info = scene_manager_global.discovered_scenes[scene_key]
		var scene_directory = scene_info.get("directory", "")
		
		# Direct directory match: animation/basic_animation
		if scene_directory == path:
			print("✅ Found scene by directory match: " + scene_key + " (dir: " + scene_directory + ")")
			return scene_info
		
		# Category/subfolder construction
		var scene_category = scene_info.get("category", "")
		var scene_subfolder = scene_info.get("subfolder", "")
		
		if scene_category != "" and scene_subfolder != "":
			var constructed_path = scene_category + "/" + scene_subfolder
			if constructed_path == path:
				print("✅ Found scene by category/subfolder match: " + scene_key)
				return scene_info
	
	# Strategy 4: Fuzzy matching - look for scenes that contain the path components
	if path_parts.size() >= 2:
		var category = path_parts[0]
		var folder = path_parts[1]
		
		print("🔍 Fuzzy search for category: '" + category + "', folder: '" + folder + "'")
		
		for scene_key in scene_manager_global.discovered_scenes.keys():
			var scene_info = scene_manager_global.discovered_scenes[scene_key]
			
			# Check if scene key contains both category and folder
			if scene_key.contains(category) and scene_key.contains(folder):
				print("✅ Found scene by fuzzy key match: " + scene_key)
				return scene_info
	
	# Strategy 5: Debug all available scenes and their paths
	print("❌ No scene found for path: " + path)
	print("📋 Available scenes and their paths:")
	for key in scene_manager_global.discovered_scenes.keys():
		var info = scene_manager_global.discovered_scenes[key]
		var dir = info.get("directory", "")
		var category = info.get("category", "")
		var subfolder = info.get("subfolder", "")
		var name = info.get("name", "")
		print("  - " + key + ":")
		print("    directory: '" + dir + "'")
		print("    category: '" + category + "', subfolder: '" + subfolder + "'")
		print("    name: '" + name + "'")
		print("    Expected path: '" + (category + "/" + subfolder if subfolder != "" else category + "/" + name) + "'")
	
	return {}

func _show_scene_browser():
	print("📁 Showing scene browser")
	_create_scene_browser_ui()

func _create_scene_browser_ui():
	print("🎨 Using native Godot Tree control for file browser")
	
	# Create the main UI container
	selector_ui = Control.new()
	selector_ui.name = "SceneBrowserUI"
	selector_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(selector_ui)
	
	# Create background overlay
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selector_ui.add_child(bg)
	
	# Get viewport size for proper scaling
	var viewport_size = get_viewport().get_visible_rect().size
	print("🎨 Viewport size: " + str(viewport_size))
	
	# Create main panel with adaptive sizing
	var panel = Panel.new()
	panel.name = "MainPanel"
	
	# Use 90% of screen width/height, but with min/max constraints
	var panel_width = max(800, min(1400, viewport_size.x * 0.9))
	var panel_height = max(600, min(1000, viewport_size.y * 0.9))
	panel.size = Vector2(panel_width, panel_height)
	panel.position = (viewport_size - panel.size) / 2
	
	print("🎨 Panel size: " + str(panel.size) + " at position: " + str(panel.position))
	
	# Panel styling
	var panel_bg = StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.95, 0.95, 0.95)
	panel_bg.border_width_left = 2
	panel_bg.border_width_right = 2
	panel_bg.border_width_top = 2
	panel_bg.border_width_bottom = 2
	panel_bg.border_color = Color(0.7, 0.7, 0.7)
	panel_bg.corner_radius_top_left = 8
	panel_bg.corner_radius_top_right = 8
	panel_bg.corner_radius_bottom_left = 8
	panel_bg.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_bg)
	
	selector_ui.add_child(panel)
	
	# Create content container directly in panel
	var content = VBoxContainer.new()
	content.name = "Content"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 15)
	content.add_theme_constant_override("margin_left", 20)
	content.add_theme_constant_override("margin_right", 20)
	content.add_theme_constant_override("margin_top", 20)
	content.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(content)
	
	# Add title bar
	var title_bar = _create_simple_title_bar()
	content.add_child(title_bar)
	
	# Create the Tree control with proper sizing
	var tree = Tree.new()
	tree.name = "SceneTree"
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.columns = 1
	tree.hide_root = false
	tree.allow_reselect = true
	tree.select_mode = Tree.SELECT_SINGLE
	tree.custom_minimum_size = Vector2(400, 300)  # Minimum size
	
	# Tree styling with responsive font sizes
	var base_font_size = max(12, min(16, viewport_size.y / 50))  # Scale font with screen height
	tree.add_theme_font_size_override("font_size", int(base_font_size))
	tree.add_theme_constant_override("item_margin", max(4, int(base_font_size * 0.3)))
	tree.add_theme_constant_override("inner_item_margin_left", max(16, int(base_font_size * 1.2)))
	tree.add_theme_constant_override("inner_item_margin_right", 8)
	tree.add_theme_constant_override("button_margin", 4)
	tree.add_theme_constant_override("draw_relationship_lines", 1)
	tree.add_theme_constant_override("relationship_line_width", 2)
	tree.add_theme_constant_override("parent_hl_line_width", 2)
	tree.add_theme_constant_override("children_hl_line_width", 2)
	tree.add_theme_constant_override("parent_hl_line_margin", 4)
	tree.add_theme_constant_override("item_margin", max(6, int(viewport_size.y / 100)))
	
	# Add scroll behavior
	tree.scroll_horizontal_enabled = true
	tree.scroll_vertical_enabled = true
	
	print("🎨 Tree font size: " + str(base_font_size))
	
	content.add_child(tree)
	
	# Build the tree structure
	_build_native_tree(tree)
	
	# Connect tree signals
	tree.item_selected.connect(_on_tree_item_selected)
	tree.item_activated.connect(_on_tree_item_activated)
	
	is_selector_active = true
	print("✅ Responsive Tree browser created")
	print("🔍 Node hierarchy: " + selector_ui.name + "/" + panel.name + "/" + content.name + "/" + tree.name)

func _create_simple_title_bar() -> Control:
	var title_bar = HBoxContainer.new()
	title_bar.name = "TitleBar"
	title_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_theme_constant_override("separation", 10)
	
	# Get viewport for responsive sizing
	var viewport_size = get_viewport().get_visible_rect().size
	var title_font_size = max(16, min(24, viewport_size.y / 40))
	var button_font_size = max(10, min(14, viewport_size.y / 60))
	
	# Title
	var title = Label.new()
	var scene_count = scene_manager_global.discovered_scenes.size() if scene_manager_global else 0
	title.text = "🎮 Scene Browser - " + str(scene_count) + " scenes"
	title.add_theme_font_size_override("font_size", int(title_font_size))
	title.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_bar.add_child(title)
	
	# Button container
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 5)
	
	# Expand All button
	var expand_btn = Button.new()
	expand_btn.text = "📂 Expand All"
	expand_btn.add_theme_font_size_override("font_size", int(button_font_size))
	expand_btn.custom_minimum_size = Vector2(max(80, viewport_size.x / 20), max(30, viewport_size.y / 25))
	expand_btn.pressed.connect(_expand_all_folders)
	button_container.add_child(expand_btn)
	
	# Collapse All button
	var collapse_btn = Button.new()
	collapse_btn.text = "📁 Collapse All"
	collapse_btn.add_theme_font_size_override("font_size", int(button_font_size))
	collapse_btn.custom_minimum_size = Vector2(max(80, viewport_size.x / 20), max(30, viewport_size.y / 25))
	collapse_btn.pressed.connect(_collapse_all_folders)
	button_container.add_child(collapse_btn)
	
	title_bar.add_child(button_container)
	
	print("🎨 Title font size: " + str(title_font_size) + ", Button font size: " + str(button_font_size))
	
	return title_bar

func _build_native_tree(tree: Tree):
	if not scene_manager_global:
		print("❌ SceneManagerGlobal not available for tree building")
		return
		
	print("🎨 Building native Tree structure...")
	
	# Create root item
	var root = tree.create_item()
	root.set_text(0, "📁 All Scenes")
	root.set_icon(0, null)
	root.set_selectable(0, false)
	
	# Build from scene tree data
	_add_tree_folders(scene_manager_global.scene_tree, root, tree)
	
	print("✅ Tree structure built")

func _add_tree_folders(tree_data: Dictionary, parent_item: TreeItem, tree: Tree):
	var sorted_keys = tree_data.keys()
	sorted_keys.sort()
	
	for key in sorted_keys:
		var item_data = tree_data[key]
		
		if item_data.has("type") and item_data.type == "folder":
			# Create folder item
			var folder_item = tree.create_item(parent_item)
			folder_item.set_text(0, "📁 " + item_data.title)
			folder_item.set_selectable(0, false)
			folder_item.collapsed = false  # Start expanded
			
			# Store folder metadata
			folder_item.set_metadata(0, {
				"type": "folder",
				"path": item_data.get("path", ""),
				"title": item_data.title
			})
			
			# Add scenes directly in this folder
			if item_data.has("scenes") and item_data.scenes.size() > 0:
				for scene_key in item_data.scenes:
					_add_tree_scene(scene_key, folder_item, tree)
			
			# Add subfolders
			if item_data.has("children") and item_data.children.size() > 0:
				_add_tree_folders(item_data.children, folder_item, tree)

func _add_tree_scene(scene_key: String, parent_item: TreeItem, tree: Tree):
	if not scene_manager_global:
		return
		
	var scene_info = scene_manager_global.discovered_scenes.get(scene_key, {})
	if scene_info.is_empty():
		return
	
	var scene_title = scene_info.get("title", scene_key)
	
	# Create scene item
	var scene_item = tree.create_item(parent_item)
	scene_item.set_text(0, "🎮 " + scene_title)
	scene_item.set_selectable(0, true)
	
	# Store scene metadata
	scene_item.set_metadata(0, {
		"type": "scene",
		"scene_key": scene_key,
		"scene_path": scene_info.path,
		"title": scene_title
	})
	
	print("✅ Added tree scene: " + scene_title)

func _on_tree_item_selected():
	if not selector_ui:
		print("❌ selector_ui is null")
		return
	
	var tree_path = "MainPanel/Content/SceneTree"
	var tree = selector_ui.get_node_or_null(tree_path)
	
	if not tree:
		print("❌ Tree not found at path: " + tree_path)
		print("🔍 Available children of selector_ui:")
		_debug_print_children(selector_ui, 0)
		return
	
	var selected_item = tree.get_selected()
	
	if not selected_item:
		return
	
	var metadata = selected_item.get_metadata(0)
	if not metadata:
		return
	
	print("🔍 Selected: " + metadata.get("title", "Unknown"))

func _on_tree_item_activated():
	if not selector_ui:
		print("❌ selector_ui is null")
		return
	
	var tree_path = "MainPanel/Content/SceneTree"
	var tree = selector_ui.get_node_or_null(tree_path)
	
	if not tree:
		print("❌ Tree not found at path: " + tree_path)
		return
	
	var selected_item = tree.get_selected()
	
	if not selected_item:
		return
	
	var metadata = selected_item.get_metadata(0)
	if not metadata:
		return
	
	# Only load scenes, not folders
	if metadata.get("type") == "scene":
		var scene_path = metadata.get("scene_path", "")
		if scene_path != "":
			print("🔗 Loading scene from tree: " + scene_path)
			get_tree().change_scene_to_file(scene_path)

func _expand_all_folders():
	if not selector_ui:
		return
	
	var tree = selector_ui.get_node_or_null("MainPanel/Content/SceneTree")
	if tree:
		_set_all_collapsed(tree.get_root(), false)

func _collapse_all_folders():
	if not selector_ui:
		return
	
	var tree = selector_ui.get_node_or_null("MainPanel/Content/SceneTree")
	if tree:
		_set_all_collapsed(tree.get_root(), true)

func _set_all_collapsed(item: TreeItem, collapsed: bool):
	if not item:
		return
	
	var metadata = item.get_metadata(0)
	if metadata and metadata.get("type") == "folder":
		item.collapsed = collapsed
	
	# Recurse through children
	var child = item.get_first_child()
	while child:
		_set_all_collapsed(child, collapsed)
		child = child.get_next()

func _debug_print_children(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		_debug_print_children(child, depth + 1)

func _show_all_scenes():
	print("🏠 Expanding all folders in tree...")
	_expand_all_folders()

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_selector_active:
		_hide_scene_browser()

func _hide_scene_browser():
	if selector_ui:
		selector_ui.queue_free()
		is_selector_active = false
		folder_states.clear()  # Clear folder states when hiding browser
