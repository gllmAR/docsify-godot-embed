extends Node2D

# Scene manager now uses the autoload for data-driven discovery
var selector_ui: Control
var is_selector_active = false
var current_category = ""

# Add progress tracking
var completed_demos: Dictionary = {}
var user_progress: Dictionary = {}

func _ready():
	_load_user_progress()
	# Wait for autoload to be ready then get categories
	await get_tree().process_frame
	await get_tree().process_frame  # Give extra time for autoload
	
	var available_categories = SceneManagerGlobal.available_categories
	print("🔍 Scene Manager ready. Available categories: ", available_categories.keys())
	print("🔍 Total categories found: ", available_categories.size())
	
	# Debug: Print details of each category
	for cat_key in available_categories.keys():
		var cat_info = available_categories[cat_key]
		print("📁 Category: " + cat_key)
		print("   Title: " + str(cat_info.get("title", "N/A")))
		print("   Scenes: " + str(cat_info.get("scenes", {}).size()))
		for scene_key in cat_info.get("scenes", {}).keys():
			var scene_info = cat_info.scenes[scene_key]
			print("     - " + scene_key + ": " + str(scene_info.get("title", "N/A")))
	
	var params = _parse_url_parameters()
	var category = params.get("category", "")
	var scene = params.get("scene", "")
	
	if category != "" and scene != "":
		current_category = category
		if _is_valid_scene(category, scene):
			_load_scene(category, scene)
		else:
			print("⚠️ Invalid scene specified: " + category + "/" + scene)
			_show_file_navigator()
	elif category != "":
		current_category = category
		if SceneManagerGlobal.available_categories.has(category):
			_show_file_navigator(category)  # Show navigator with category expanded
		else:
			print("⚠️ Invalid category specified: " + category)
			_show_file_navigator()
	else:
		_show_file_navigator()

func _parse_url_parameters() -> Dictionary:
	var params = {}
	if OS.has_feature("web"):
		# Get all URL parameters
		var url_params = {}
		
		# Parse demo parameter (primary) with URL decoding
		var demo_result = JavaScriptBridge.eval("decodeURIComponent(new URLSearchParams(window.location.search).get('demo') || '')")
		if demo_result and demo_result != "":
			var demo_parts = demo_result.split("/")
			if demo_parts.size() >= 2:
				params["category"] = demo_parts[0]
				params["scene"] = demo_parts[1]
				print("🔗 Demo path parsed: %s -> category: %s, scene: %s" % [demo_result, demo_parts[0], demo_parts[1]])
			else:
				print("⚠️ Invalid demo path format: %s (expected: category/scene)" % demo_result)
		
		# Parse all other URL parameters for passing to the scene (with URL decoding)
		var all_params_js = """
		(function() {
			var params = {};
			var urlParams = new URLSearchParams(window.location.search);
			for (var pair of urlParams.entries()) {
				try {
					params[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
				} catch (e) {
					// Fallback for malformed URL encoding
					params[pair[0]] = pair[1];
				}
			}
			return JSON.stringify(params);
		})()
		"""
		
		var all_params_json = JavaScriptBridge.eval(all_params_js)
		if all_params_json:
			var json = JSON.new()
			var parse_result = json.parse(all_params_json)
			if parse_result == OK:
				url_params = json.data
				
				# Extract additional parameters (excluding 'demo')
				for key in url_params.keys():
					if key != "demo":
						# Convert string values to appropriate types
						var value = url_params[key]
						
						# Convert boolean strings
						if value == "true":
							params[key] = true
						elif value == "false":
							params[key] = false
						elif value.is_valid_float():
							params[key] = value.to_float()
						elif value.is_valid_int():
							params[key] = value.to_int()
						else:
							params[key] = value
						
						print("🔗 Additional parameter: %s = %s (%s)" % [key, params[key], typeof(params[key])])
		
		print("🔗 URL parameters - demo: %s -> category: %s, scene: %s" % [
			demo_result if demo_result else "none", 
			params.get("category", "none"), 
			params.get("scene", "none")
		])
		
		if params.size() > 2:  # More than just category and scene
			print("🔗 Additional parameters: %s" % str(params))
	else:
		# For desktop testing, you can add test parameters here
		print("🔗 Running in desktop mode - no URL parameters available")
	
	return params

func _show_category_selector():
	print("📂 Showing file navigator")
	_show_file_navigator()

func _show_scene_selector(category: String):
	print("🎮 Showing file navigator with category: ", category)
	_show_file_navigator(category)

func _show_file_navigator(expanded_category: String = ""):
	print("📁 Showing file navigator")
	is_selector_active = true
	selector_ui = await _create_file_navigator_ui(expanded_category)
	add_child(selector_ui)

func _create_file_navigator_ui(expanded_category: String = "") -> Control:
	print("🔧 Creating responsive file navigator UI...")
	print("   Available categories: " + str(SceneManagerGlobal.available_categories.keys()))
	print("   Expanded category: " + expanded_category)
	
	var main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.name = "FileNavigatorUI"
	main_container.z_index = 1000
	
	# Get viewport size for responsive calculations
	var viewport_size = get_viewport().get_visible_rect().size
	main_container.size = viewport_size
	main_container.position = Vector2.ZERO
	
	print("🔧 Viewport size: " + str(viewport_size))
	
	# Detect device type for responsive design
	var is_mobile = viewport_size.x < 768  # Mobile breakpoint
	var is_tablet = viewport_size.x >= 768 and viewport_size.x < 1024  # Tablet breakpoint
	var is_desktop = viewport_size.x >= 1024  # Desktop breakpoint
	
	print("🔧 Device type: " + ("Mobile" if is_mobile else ("Tablet" if is_tablet else "Desktop")))
	
	# Semi-transparent background
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.size = viewport_size
	background.position = Vector2.ZERO
	background.color = Color(0, 0, 0, 0.95)
	background.name = "Background"
	background.z_index = 1001
	main_container.add_child(background)
	
	# Main panel with responsive sizing
	var panel = Panel.new()
	panel.name = "MainPanel"
	panel.z_index = 1002
	
	# Responsive panel sizing and positioning
	if is_mobile:
		# Mobile: Full screen with minimal margin
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.size = viewport_size
		panel.position = Vector2.ZERO
	else:
		# Tablet/Desktop: Centered with margins
		var panel_width = min(viewport_size.x * 0.9, 900)  # Max 900px, 90% of screen
		var panel_height = min(viewport_size.y * 0.9, 700)  # Max 700px, 90% of screen
		var panel_x = (viewport_size.x - panel_width) / 2
		var panel_y = (viewport_size.y - panel_height) / 2
		
		panel.position = Vector2(panel_x, panel_y)
		panel.size = Vector2(panel_width, panel_height)
	
	# Panel styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.2, 0.98)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.4, 0.6, 1.0, 0.8)
	
	if not is_mobile:
		style_box.corner_radius_top_left = 12
		style_box.corner_radius_top_right = 12
		style_box.corner_radius_bottom_left = 12
		style_box.corner_radius_bottom_right = 12
	
	panel.add_theme_stylebox_override("panel", style_box)
	main_container.add_child(panel)
	
	# Force layout update
	main_container.queue_redraw()
	await get_tree().process_frame
	
	# Responsive margin container
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.name = "MarginContainer"
	margin_container.z_index = 1003
	
	# Responsive margins
	var margin_h = 20 if is_mobile else 30
	var margin_v = 15 if is_mobile else 25
	
	margin_container.add_theme_constant_override("margin_left", margin_h)
	margin_container.add_theme_constant_override("margin_right", margin_h)
	margin_container.add_theme_constant_override("margin_top", margin_v)
	margin_container.add_theme_constant_override("margin_bottom", margin_v)
	panel.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20 if is_mobile else 15)
	vbox.name = "MainVBox"
	vbox.z_index = 1004
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin_container.add_child(vbox)
	
	# Header with responsive sizing
	var header = HBoxContainer.new()
	header.name = "Header"
	header.z_index = 1005
	header.custom_minimum_size = Vector2(0, 60 if is_mobile else 80)
	vbox.add_child(header)
	
	# Title with responsive font
	var title = Label.new()
	title.text = "📁 Select a Demo"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.name = "Title"
	title.z_index = 1006
	
	# Responsive font size
	var title_font_size = 20 if is_mobile else (28 if is_tablet else 32)
	title.add_theme_font_size_override("font_size", title_font_size)
	title.add_theme_color_override("font_color", Color.WHITE)
	header.add_child(title)
	
	# Close button with responsive sizing
	var close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(50 if is_mobile else 60, 50 if is_mobile else 60)
	close_button.add_theme_font_size_override("font_size", 20 if is_mobile else 24)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
	close_style.border_width_left = 2
	close_style.border_width_right = 2
	close_style.border_width_top = 2
	close_style.border_width_bottom = 2
	close_style.border_color = Color.WHITE
	close_style.corner_radius_top_left = 6
	close_style.corner_radius_top_right = 6
	close_style.corner_radius_bottom_left = 6
	close_style.corner_radius_bottom_right = 6
	close_button.add_theme_stylebox_override("normal", close_style)
	
	close_button.pressed.connect(_on_navigator_close)
	close_button.name = "CloseButton"
	close_button.z_index = 1006
	header.add_child(close_button)
	
	# Scrollable content area
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.name = "ScrollContainer"
	scroll_container.z_index = 1005
	
	# Responsive minimum height
	var min_scroll_height = 250 if is_mobile else 350
	scroll_container.custom_minimum_size = Vector2(0, min_scroll_height)
	vbox.add_child(scroll_container)
	
	var tree_container = VBoxContainer.new()
	tree_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree_container.add_theme_constant_override("separation", 12 if is_mobile else 15)
	tree_container.name = "TreeContainer"
	tree_container.z_index = 1006
	scroll_container.add_child(tree_container)
	
	# Create categories with responsive layout
	var sorted_categories = SceneManagerGlobal.available_categories.keys()
	sorted_categories.sort()
	
	print("🔧 Creating tree for " + str(sorted_categories.size()) + " categories")
	
	if sorted_categories.size() == 0:
		var error_label = Label.new()
		error_label.text = "No demo categories found. Check the scenes directory structure."
		error_label.add_theme_color_override("font_color", Color.RED)
		error_label.add_theme_font_size_override("font_size", 18 if is_mobile else 24)
		error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tree_container.add_child(error_label)
	else:
		for category_key in sorted_categories:
			var category_info = SceneManagerGlobal.available_categories[category_key]
			var is_expanded = true  # Show all by default for better UX
			
			# Create category container
			var category_container = VBoxContainer.new()
			category_container.add_theme_constant_override("separation", 8 if is_mobile else 10)
			category_container.name = "Category_" + category_key
			category_container.z_index = 1007
			tree_container.add_child(category_container)
			
			# Category header
			var category_header = _create_responsive_category_header(category_key, category_info, is_expanded, viewport_size, is_mobile)
			category_container.add_child(category_header)
			
			# Scene list
			if is_expanded:
				var scene_list = _create_responsive_scene_list(category_key, category_info, viewport_size, is_mobile)
				category_container.add_child(scene_list)
	
	# Instructions with responsive text
	var instructions = Label.new()
	instructions.text = "Click on any demo to launch it" + (" • Tap ✕ to close" if is_mobile else " • Click folders to expand/collapse • ESC to close")
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.name = "Instructions"
	instructions.z_index = 1005
	instructions.custom_minimum_size = Vector2(0, 30 if is_mobile else 40)
	
	var instruction_font_size = 12 if is_mobile else (14 if is_tablet else 16)
	instructions.add_theme_font_size_override("font_size", instruction_font_size)
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0, 0.9))
	vbox.add_child(instructions)
	
	# Final layout update - REMOVE this problematic line
	main_container.queue_redraw()
	# call_deferred("_force_layout_update", main_container)  # REMOVE THIS LINE
	
	print("🔧 Responsive file navigator UI created")
	print("🔧 Device type: " + ("Mobile" if is_mobile else ("Tablet" if is_tablet else "Desktop")))
	
	return main_container

# Remove this method entirely since it's not needed
# func _force_layout_update(container: Control):
#	# This method was causing the error

func _create_responsive_category_header(category_key: String, category_info: Dictionary, is_expanded: bool, viewport_size: Vector2, is_mobile: bool) -> Control:
	var header_container = Control.new()
	header_container.custom_minimum_size = Vector2(0, 50 if is_mobile else 70)
	header_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_container.name = "CategoryHeader_" + category_key
	
	# Category button
	var folder_button = Button.new()
	folder_button.flat = false
	folder_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	folder_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	folder_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	folder_button.name = "CategoryButton_" + category_key
	folder_button.mouse_filter = Control.MOUSE_FILTER_PASS
	folder_button.focus_mode = Control.FOCUS_ALL
	
	# Responsive styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	var border_width = 2 if is_mobile else 3
	button_style.border_width_left = border_width
	button_style.border_width_right = border_width
	button_style.border_width_top = border_width
	button_style.border_width_bottom = border_width
	button_style.border_color = Color(0.4, 0.6, 1.0, 0.8)
	
	var corner_radius = 6 if is_mobile else 8
	button_style.corner_radius_top_left = corner_radius
	button_style.corner_radius_top_right = corner_radius
	button_style.corner_radius_bottom_left = corner_radius
	button_style.corner_radius_bottom_right = corner_radius
	folder_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.6, 0.9)
	folder_button.add_theme_stylebox_override("hover", hover_style)
	
	# Responsive button height and text
	var button_height = 45 if is_mobile else 60
	folder_button.custom_minimum_size = Vector2(0, button_height)
	
	var folder_icon = "📂" if is_expanded else "📁"
	var scene_count = category_info.get("scenes", {}).size()
	var button_text = "%s %s (%d demos)" % [folder_icon, category_info.get("title", category_key), scene_count]
	folder_button.text = button_text
	
	# Responsive font size
	var header_font_size = 14 if is_mobile else (18 if viewport_size.x < 1200 else 20)
	folder_button.add_theme_font_size_override("font_size", header_font_size)
	folder_button.add_theme_color_override("font_color", Color.WHITE)
	
	# Connect signals
	folder_button.pressed.connect(func():
		print("🔧 Category button pressed: " + category_key)
		_on_category_folder_clicked(category_key)
	)
	
	# Visual feedback
	folder_button.mouse_entered.connect(func(): 
		folder_button.modulate = Color(1.2, 1.2, 1.2)
	)
	folder_button.mouse_exited.connect(func(): 
		folder_button.modulate = Color.WHITE
	)
	
	header_container.add_child(folder_button)
	return header_container

func _create_responsive_scene_list(category_key: String, category_info: Dictionary, viewport_size: Vector2, is_mobile: bool) -> Control:
	var scene_container = VBoxContainer.new()
	scene_container.add_theme_constant_override("separation", 4 if is_mobile else 6)
	
	# Responsive indentation
	var indent_container = HBoxContainer.new()
	scene_container.add_child(indent_container)
	
	var spacer = Control.new()
	var indent_size = 20 if is_mobile else 30
	spacer.custom_minimum_size = Vector2(indent_size, 0)
	indent_container.add_child(spacer)
	
	# Scene list
	var scenes_vbox = VBoxContainer.new()
	scenes_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scenes_vbox.add_theme_constant_override("separation", 3 if is_mobile else 4)
	indent_container.add_child(scenes_vbox)
	
	# Sort and add scenes
	var sorted_scenes = category_info.scenes.keys()
	sorted_scenes.sort()
	
	for scene_key in sorted_scenes:
		var scene_info = category_info.scenes[scene_key]
		var scene_item = _create_responsive_scene_item(category_key, scene_key, scene_info, viewport_size, is_mobile)
		scenes_vbox.add_child(scene_item)
	
	return scene_container

func _create_responsive_scene_item(category_key: String, scene_key: String, scene_info: Dictionary, viewport_size: Vector2, is_mobile: bool) -> Control:
	var item_container = Control.new()
	item_container.custom_minimum_size = Vector2(0, 40 if is_mobile else 50)
	item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_container.name = "SceneItem_" + scene_key
	
	# Scene button
	var scene_button = Button.new()
	scene_button.flat = false
	scene_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	scene_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_button.name = "SceneButton_" + scene_key
	scene_button.mouse_filter = Control.MOUSE_FILTER_PASS
	scene_button.focus_mode = Control.FOCUS_ALL
	
	# Enhanced styling with completion indicators
	var scene_style = StyleBoxFlat.new()
	var is_completed = completed_demos.get(category_key + "/" + scene_key, false)
	scene_style.bg_color = Color(0.15, 0.4, 0.15, 0.8) if is_completed else Color(0.15, 0.2, 0.3, 0.8)
	
	var border_width = 1 if is_mobile else 2
	scene_style.border_width_left = border_width
	scene_style.border_width_right = border_width
	scene_style.border_width_top = border_width
	scene_style.border_width_bottom = border_width
	scene_style.border_color = Color.GREEN if is_completed else Color(0.3, 0.4, 0.6, 0.7)
	
	var corner_radius = 4 if is_mobile else 6
	scene_style.corner_radius_top_left = corner_radius
	scene_style.corner_radius_top_right = corner_radius
	scene_style.corner_radius_bottom_left = corner_radius
	scene_style.corner_radius_bottom_right = corner_radius
	scene_button.add_theme_stylebox_override("normal", scene_style)
	
	# Hover style
	var hover_style = scene_style.duplicate()
	hover_style.bg_color = Color(0.2, 0.3, 0.4, 0.9)
	scene_button.add_theme_stylebox_override("hover", hover_style)
	
	# Responsive height and text
	var scene_button_height = 35 if is_mobile else 45
	scene_button.custom_minimum_size = Vector2(0, scene_button_height)
	
	var scene_title = scene_info.get("title", scene_key)
	var completion_icon = "✅ " if is_completed else "🎮 "
	var difficulty_stars = "⭐".repeat(scene_info.get("difficulty", 1))
	scene_button.text = completion_icon + scene_title + " " + difficulty_stars
	
	# Responsive font size
	var scene_font_size = 12 if is_mobile else (14 if viewport_size.x < 1200 else 16)
	scene_button.add_theme_font_size_override("font_size", scene_font_size)
	scene_button.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))
	
	# Connect signals
	scene_button.pressed.connect(func():
		print("🎯 Scene button clicked: " + category_key + "/" + scene_key)
		_on_scene_selected(category_key, scene_key)
	)
	
	# Visual feedback
	scene_button.mouse_entered.connect(func(): 
		scene_button.modulate = Color(1.1, 1.1, 1.1)
	)
	scene_button.mouse_exited.connect(func(): 
		scene_button.modulate = Color.WHITE
	)
	
	item_container.add_child(scene_button)
	return item_container

func _on_navigator_close():
	print("🔙 Navigator closed")
	
	# Remove current selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	is_selector_active = false
	
	# Update URL if running in web - clear demo parameter with proper encoding
	if OS.has_feature("web"):
		var new_url = "window.location.href.split('?')[0]"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
		print("🔗 URL cleared to base path")
	
	current_category = ""

func _on_category_folder_clicked(category_key: String):
	print("📁 Folder clicked: ", category_key)
	print("🔄 Current categories available: ", SceneManagerGlobal.available_categories.keys())
	
	# Remove current selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	# Update URL if running in web with proper encoding
	if OS.has_feature("web"):
		var encoded_category = _url_encode(category_key)
		var new_url = "window.location.href.split('?')[0] + '?demo=" + encoded_category + "'"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
		print("🔗 URL updated to category: %s (encoded: %s)" % [category_key, encoded_category])
	
	# Toggle folder - if it was the current expanded category, collapse it
	var new_expanded = category_key if current_category != category_key else ""
	current_category = new_expanded
	
	# Recreate navigator with new expansion state
	await _show_file_navigator(new_expanded)

func _on_scene_selected(category: String, scene_key: String):
	print("🎯 Scene selected: ", category, "/", scene_key)
	print("🔄 Checking if scene exists in available categories...")
	
	# Verify the scene exists
	if not SceneManagerGlobal.available_categories.has(category):
		print("❌ Category not found: " + category)
		print("Available categories: " + str(SceneManagerGlobal.available_categories.keys()))
		return
		
	if not SceneManagerGlobal.available_categories[category]["scenes"].has(scene_key):
		print("❌ Scene not found: " + scene_key + " in category " + category)
		print("Available scenes: " + str(SceneManagerGlobal.available_categories[category]["scenes"].keys()))
		return
	
	# Remove selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	is_selector_active = false
	
	# Update URL if running in web with proper encoding
	if OS.has_feature("web"):
		var encoded_category = _url_encode(category)
		var encoded_scene = _url_encode(scene_key)
		var demo_path = encoded_category + "/" + encoded_scene
		var new_url = "window.location.href.split('?')[0] + '?demo=" + demo_path + "'"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
		print("🔗 URL updated to scene: %s/%s (encoded: %s)" % [category, scene_key, demo_path])
	
	# Load the selected scene
	_load_scene(category, scene_key)

# Helper function for URL encoding
func _url_encode(text: String) -> String:
	if OS.has_feature("web"):
		# Use JavaScript's encodeURIComponent for proper URL encoding
		var js_code = "encodeURIComponent('" + text.replace("'", "\\'") + "')"
		var encoded = JavaScriptBridge.eval(js_code)
		return encoded if encoded else text
	else:
		# Simple fallback for desktop (basic character replacement)
		return text.replace(" ", "%20").replace("/", "%2F").replace("?", "%3F").replace("#", "%23")

func _load_scene(category: String, scene_key: String):
	print("🎯 Loading scene: " + category + "/" + scene_key)
	
	var available_categories = SceneManagerGlobal.available_categories
	if available_categories.has(category) and available_categories[category]["scenes"].has(scene_key):
		var scene_info = available_categories[category]["scenes"][scene_key]
		var scene_path = scene_info.path
		
		print("🔄 Loading scene from: " + scene_path)
		print("🔄 Scene belongs to category: " + category)
		
		# Clear any existing scene children before loading new one
		_clear_loaded_scenes()
		
		var scene_resource = load(scene_path)
		if scene_resource:
			var instance = scene_resource.instantiate()
			add_child(instance)
			
			# Set the category property on the loaded scene if it has one
			if instance.has_method("set_category"):
				instance.set_category(category)
			elif "category" in instance:
				instance.category = category
			
			# Pass additional URL parameters to the scene
			var params = _parse_url_parameters()
			if instance.has_method("set_parameters"):
				instance.set_parameters(params)
				print("📋 Passed parameters to scene: %s" % str(params))
			elif instance.has_method("apply_url_parameters"):
				instance.apply_url_parameters(params)
				print("📋 Applied URL parameters to scene: %s" % str(params))
			else:
				# Try to set individual properties using 'in' operator
				for key in params.keys():
					if key != "category" and key != "scene" and key in instance:
						instance.set(key, params[key])
						print("📋 Set scene property: %s = %s" % [key, params[key]])
			
			print("✅ Loaded scene: " + category + "/" + scene_key + " (" + scene_info.title + ")")
			print("📁 Scene category set to: " + category)
			
			# Ensure the scene fills the viewport properly
			if instance is Control:
				instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		else:
			print("❌ Failed to load scene resource: " + scene_path)
			print("⚠️ Scene file not found or invalid: " + scene_path)
			# Fallback to navigator
			_show_file_navigator()
	else:
		print("❌ Invalid scene: " + category + "/" + scene_key)
		print("❌ Available categories: " + str(available_categories.keys()))
		if available_categories.has(category):
			print("❌ Available scenes in " + category + ": " + str(available_categories[category]["scenes"].keys()))
		_show_file_navigator()

func _clear_loaded_scenes():
	# Remove any previously loaded scene instances
	for child in get_children():
		if child != selector_ui and child.get_script():
			print("🧹 Removing previous scene: " + str(child))
			child.queue_free()

func _is_valid_scene(category: String, scene: String) -> bool:
	var available_categories = SceneManagerGlobal.available_categories
	return available_categories.has(category) and available_categories[category].scenes.has(scene)

# Add keyboard input handling for better UX
func _input(event):
	if is_selector_active and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_navigator_close()

func _load_user_progress():
	# Load user progress from a file or database
	# For demo purposes, we'll simulate with static data
	completed_demos = {
		"category1": {"scene1": true, "scene2": false},
		"category2": {"scene1": true},
		"category3": {"scene1": false, "scene2": false, "scene3": true},
	}
	
	# Calculate user progress for each category
	user_progress.clear()
	for category in completed_demos.keys():
		var scenes = completed_demos[category]
		var total_scenes = scenes.size()
		var completed_scenes = 0
		
		for completed in scenes.values():
			if completed:
				completed_scenes += 1
		
		var progress_percentage = (completed_scenes / total_scenes) * 100
		user_progress[category] = {
			"completed_scenes": completed_scenes,
			"total_scenes": total_scenes,
			"progress_percentage": progress_percentage,
		}
	
	print("📊 User progress loaded: ", user_progress)

func _save_user_progress():
	# Save user progress to a file or database
	print("💾 User progress saved: ", completed_demos)

func _on_scene_completed(category: String, scene_key: String):
	# Mark a scene as completed for the user
	if completed_demos.has(category) and completed_demos[category].has(scene_key):
		completed_demos[category][scene_key] = true
		print("✅ Scene marked as completed: " + category + "/" + scene_key)
		
		# Update user progress
		_save_user_progress()
		_update_scene_completion_indicator(category, scene_key, true)
	else:
		print("❌ Invalid scene or category for completion: " + category + "/" + scene_key)

func _update_scene_completion_indicator(category: String, scene_key: String, is_completed: bool):
	# Update the UI indicator for scene completion
	var scene_item = selector_ui.get_node("TreeContainer/Category_" + category + "/SceneItem_" + scene_key)
	if scene_item:
		var completion_icon = scene_item.get_node("CompletionIcon")
		if completion_icon:
			completion_icon.visible = is_completed
			print("🔄 Scene completion indicator updated: " + category + "/" + scene_key + " - Completed: " + str(is_completed))
		else:
			print("⚠️ Completion icon not found for scene item: " + scene_key)
	else:
		print("⚠️ Scene item not found for category: " + category)
