extends Node2D

# Lean scene manager focused on navigation and scene loading
var selector_ui: Control
var is_selector_active = false

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("🔍 Scene Manager starting in %s mode" % ("web" if OS.has_feature("web") else "desktop"))
	print("🔍 Available categories: " + str(SceneManagerGlobal.available_categories.keys()))
	
	# Debug: Print all discovered scenes in web mode
	if OS.has_feature("web"):
		for category_key in SceneManagerGlobal.available_categories.keys():
			var category_info = SceneManagerGlobal.available_categories[category_key]
			print("📁 Category: " + category_key + " (" + str(category_info.scenes.size()) + " scenes)")
			for scene_key in category_info.scenes.keys():
				var scene_info = category_info.scenes[scene_key]
				print("  🎮 " + scene_key + ": " + scene_info.title + " -> " + scene_info.path)
	
	var params = _parse_url_parameters()
	var category = params.get("category", "")
	var scene = params.get("scene", "")
	
	if category != "" and scene != "":
		if _is_valid_scene(category, scene):
			_load_scene(category, scene)
		else:
			print("⚠️ Invalid scene: " + category + "/" + scene)
			_show_file_navigator()
	elif category != "":
		if SceneManagerGlobal.available_categories.has(category):
			_show_file_navigator(category)
		else:
			print("⚠️ Invalid category: " + category)
			_show_file_navigator()
	else:
		_show_file_navigator()

func _parse_url_parameters() -> Dictionary:
	var params = {}
	if not OS.has_feature("web"):
		return params
	
	var scene_result = JavaScriptBridge.eval("decodeURIComponent(new URLSearchParams(window.location.search).get('scene') || '')")
	if scene_result and scene_result != "":
		var scene_parts = scene_result.split("/")
		if scene_parts.size() >= 2:
			params["category"] = scene_parts[0]
			params["scene"] = scene_parts[1]
			print("🔗 Scene path: %s -> category: %s, scene: %s" % [scene_result, scene_parts[0], scene_parts[1]])
	
	return params

func _show_file_navigator(expanded_category: String = ""):
	print("📁 Showing file navigator")
	is_selector_active = true
	selector_ui = _create_file_navigator_ui(expanded_category)
	add_child(selector_ui)

func _create_file_navigator_ui(expanded_category: String = "") -> Control:
	var main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.name = "FileNavigatorUI"
	
	# Background
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.9)
	main_container.add_child(background)
	
	# Main panel
	var panel = Panel.new()
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_width = min(viewport_size.x * 0.8, 800)
	var panel_height = min(viewport_size.y * 0.8, 600)
	panel.position = Vector2((viewport_size.x - panel_width) / 2, (viewport_size.y - panel_height) / 2)
	panel.size = Vector2(panel_width, panel_height)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	main_container.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	# Header
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "📁 Select Demo"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.pressed.connect(_on_navigator_close)
	header.add_child(close_btn)
	vbox.add_child(header)
	
	# Content
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	
	# Categories - sorted alphabetically
	var sorted_categories = SceneManagerGlobal.available_categories.keys()
	sorted_categories.sort()
	
	# Add debug info if no categories found
	if sorted_categories.size() == 0:
		var error_label = Label.new()
		error_label.text = "No scenes found. Check console for details."
		error_label.add_theme_color_override("font_color", Color.RED)
		error_label.add_theme_font_size_override("font_size", 16)
		error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(error_label)
		
		print("❌ No categories discovered in scene manager")
		print("❌ Running in: %s mode" % ("web" if OS.has_feature("web") else "desktop"))
		print("❌ Available categories dict: " + str(SceneManagerGlobal.available_categories))
	else:
		for category_key in sorted_categories:
			var category_info = SceneManagerGlobal.available_categories[category_key]
			_create_category_section(content, category_key, category_info)
	
	return main_container

func _create_category_section(parent: Node, category_key: String, category_info: Dictionary):
	# Category header
	var header_btn = Button.new()
	header_btn.text = "%s %s (%d scenes)" % [category_info.icon, category_info.title, category_info.scenes.size()]
	header_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header_btn.add_theme_font_size_override("font_size", 16)
	header_btn.pressed.connect(func(): _on_category_selected(category_key))
	parent.add_child(header_btn)
	
	# Scene list
	var indent = HBoxContainer.new()
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	indent.add_child(spacer)
	
	var scenes_vbox = VBoxContainer.new()
	scenes_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	indent.add_child(scenes_vbox)
	
	# Sort scenes alphabetically
	var sorted_scenes = category_info.scenes.keys()
	sorted_scenes.sort()
	
	for scene_key in sorted_scenes:
		var scene_info = category_info.scenes[scene_key]
		var scene_btn = Button.new()
		scene_btn.text = "🎮 " + scene_info.title
		scene_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		scene_btn.pressed.connect(func(): _on_scene_selected(category_key, scene_key))
		scenes_vbox.add_child(scene_btn)
	
	parent.add_child(indent)

func _on_navigator_close():
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	is_selector_active = false
	
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.history.pushState({}, '', window.location.href.split('?')[0])")

func _on_category_selected(category_key: String):
	if OS.has_feature("web"):
		var encoded_category = _url_encode(category_key)
		JavaScriptBridge.eval("window.history.pushState({}, '', window.location.href.split('?')[0] + '?scene=" + encoded_category + "')")
	
	_on_navigator_close()
	_show_file_navigator(category_key)

func _on_scene_selected(category: String, scene_key: String):
	if not _is_valid_scene(category, scene_key):
		print("❌ Invalid scene: " + category + "/" + scene_key)
		return
	
	_on_navigator_close()
	
	if OS.has_feature("web"):
		var scene_path = _url_encode(category) + "/" + _url_encode(scene_key)
		JavaScriptBridge.eval("window.history.pushState({}, '', window.location.href.split('?')[0] + '?scene=" + scene_path + "')")
	
	_load_scene(category, scene_key)

func _load_scene(category: String, scene_key: String):
	print("🎯 Loading scene: " + category + "/" + scene_key)
	
	# Check if the scene exists in our discovered categories
	if not SceneManagerGlobal.available_categories.has(category):
		print("❌ Category not found: " + category)
		print("Available categories: " + str(SceneManagerGlobal.available_categories.keys()))
		_show_file_navigator()
		return
	
	if not SceneManagerGlobal.available_categories[category]["scenes"].has(scene_key):
		print("❌ Scene not found: " + scene_key + " in category " + category)
		print("Available scenes: " + str(SceneManagerGlobal.available_categories[category]["scenes"].keys()))
		_show_file_navigator()
		return
	
	var scene_info = SceneManagerGlobal.available_categories[category]["scenes"][scene_key]
	var scene_path = scene_info.path
	
	print("🔄 Loading scene from: " + scene_path)
	
	_clear_loaded_scenes()
	
	var scene_resource = load(scene_path)
	if scene_resource:
		var instance = scene_resource.instantiate()
		add_child(instance)
		
		# Try to fill the viewport if it's a Control node
		if instance is Control:
			instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# Pass category information to the scene if it can accept it
		if instance.has_method("set_category"):
			instance.set_category(category)
		elif "category" in instance:
			instance.category = category
		
		print("✅ Loaded scene: " + scene_info.title)
	else:
		print("❌ Failed to load scene: " + scene_path)
		_show_file_navigator()

func _clear_loaded_scenes():
	# Clear any previously loaded scenes - be more specific about what to remove
	for child in get_children():
		if child != selector_ui:
			# Only remove nodes that are likely to be loaded scenes
			if child.get_script() != null or child is Control or child is Node2D or child is Node3D:
				print("🧹 Removing previous scene: " + str(child.name))
				child.queue_free()

func _is_valid_scene(category: String, scene: String) -> bool:
	return SceneManagerGlobal.is_valid_scene(category, scene)

func _url_encode(text: String) -> String:
	if OS.has_feature("web"):
		var js_code = "encodeURIComponent('" + text.replace("'", "\\'") + "')"
		return JavaScriptBridge.eval(js_code)
	return text

func _input(event):
	if is_selector_active and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_navigator_close()
