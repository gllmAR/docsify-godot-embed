extends Node2D

var available_categories = {
	"animation": {
		"title": "Animation Systems",
		"description": "Learn animation techniques for dynamic visual feedback",
		"icon": "🎬",
		"scenes": {
			"basic_animation": {
				"path": "res://scenes/animation/basic_animation/basic_animation.tscn",
				"title": "Basic Animation",
				"description": "Fundamental animation concepts and keyframes"
			},
			"tweening": {
				"path": "res://scenes/animation/tweening/tweening.tscn",
				"title": "Tweening & Easing",
				"description": "Smooth transitions and easing functions"
			},
			"state_machines": {
				"path": "res://scenes/animation/state_machines/state_machines.tscn",
				"title": "Animation State Machines",
				"description": "Complex animation logic with state transitions"
			}
		}
	},
	"input": {
		"title": "Input Handling",
		"description": "Master different input methods and player controls",
		"icon": "🎮",
		"scenes": {
			"keyboard_input": {
				"path": "res://scenes/input/keyboard_input/keyboard_input.tscn",
				"title": "Keyboard Input",
				"description": "Handle keyboard events and key combinations"
			},
			"mouse_input": {
				"path": "res://scenes/input/mouse_input/mouse_input.tscn",
				"title": "Mouse Input",
				"description": "Mouse clicks, movements, and interactions"
			},
			"gamepad_input": {
				"path": "res://scenes/input/gamepad_input/gamepad_input.tscn",
				"title": "Gamepad Input",
				"description": "Controller support and gamepad handling"
			}
		}
	},
	"movement": {
		"title": "Movement Techniques",
		"description": "Learn different movement techniques in game development",
		"icon": "🏃",
		"scenes": {
			"basic_movement": {
				"path": "res://scenes/movement/basic_movement/basic_movement.tscn",
				"title": "Basic Movement",
				"description": "Simple directional movement and controls"
			},
			"platformer_movement": {
				"path": "res://scenes/movement/platformer_movement/platformer_movement.tscn",
				"title": "Platformer Movement",
				"description": "Jump mechanics and gravity for platform games"
			},
			"top_down_movement": {
				"path": "res://scenes/movement/top_down_movement/top_down_movement.tscn",
				"title": "Top-Down Movement",
				"description": "8-directional movement for top-down games"
			}
		}
	},
	"physics": {
		"title": "Physics Simulation",
		"description": "Explore physics-based interactions and simulations",
		"icon": "⚡",
		"scenes": {
			"basic_physics": {
				"path": "res://scenes/physics/basic_physics/basic_physics.tscn",
				"title": "Basic Physics",
				"description": "Fundamental physics concepts and forces"
			},
			"collision_detection": {
				"path": "res://scenes/physics/collision_detection/collision_detection.tscn",
				"title": "Collision Detection",
				"description": "Detecting and responding to collisions"
			},
			"rigid_bodies": {
				"path": "res://scenes/physics/rigid_bodies/rigid_bodies.tscn",
				"title": "Rigid Bodies",
				"description": "Realistic physics with rigid body dynamics"
			}
		}
	}
}

var selector_ui: Control
var is_selector_active = false
var current_category = ""

func _ready():
	var params = _parse_url_parameters()
	var category = params.get("category", "")
	var scene = params.get("scene", "")
	
	if category != "" and scene != "":
		current_category = category
		if _is_valid_scene(category, scene):
			_load_scene(category, scene)
		else:
			_show_category_selector()
	elif category != "":
		current_category = category
		_show_scene_selector(category)
	else:
		_show_category_selector()

func _parse_url_parameters() -> Dictionary:
	var params = {}
	if OS.has_feature("web"):
		var category_result = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('category')")
		var scene_result = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('scene')")
		
		if category_result and category_result != "":
			params["category"] = category_result
		if scene_result and scene_result != "":
			params["scene"] = scene_result
		
		print("🔗 URL parameters - category: ", params.get("category", "none"), ", scene: ", params.get("scene", "none"))
	
	return params

func _is_valid_scene(category: String, scene: String) -> bool:
	return available_categories.has(category) and available_categories[category]["scenes"].has(scene)

func _show_category_selector():
	print("📂 Showing category selector")
	is_selector_active = true
	selector_ui = _create_category_selector_ui()
	add_child(selector_ui)

func _show_scene_selector(category: String):
	print("🎮 Showing scene selector for category: ", category)
	is_selector_active = true
	selector_ui = _create_scene_selector_ui(category)
	add_child(selector_ui)

func _create_category_selector_ui() -> Control:
	var main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Semi-transparent background
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.8)
	main_container.add_child(background)
	
	# Center panel container
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(center_container)
	
	# Main panel with adaptive sizing
	var panel = Panel.new()
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_width = min(max(viewport_size.x * 0.8, 400), 700)
	var panel_height = min(max(viewport_size.y * 0.7, 350), 500)
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center_container.add_child(panel)
	
	# Vertical layout with margins
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin_container.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🎮 Select a Category"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Category buttons container
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll_container)
	
	var grid = GridContainer.new()
	grid.columns = 2 if panel_width > 500 else 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	scroll_container.add_child(grid)
	
	# Create buttons for each category
	for category_key in available_categories.keys():
		var category_info = available_categories[category_key]
		var button_container = VBoxContainer.new()
		button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var button = Button.new()
		button.text = category_info.icon + " " + category_info.title
		button.custom_minimum_size = Vector2(200, 50)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_category_selected.bind(category_key))
		button_container.add_child(button)
		
		var description = Label.new()
		description.text = category_info.description
		description.custom_minimum_size = Vector2(200, 35)
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size", 11)
		button_container.add_child(description)
		
		# Show scene count
		var scene_count = Label.new()
		scene_count.text = str(category_info.scenes.size()) + " demos available"
		scene_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scene_count.add_theme_font_size_override("font_size", 10)
		scene_count.modulate = Color(0.7, 0.7, 0.7)
		button_container.add_child(scene_count)
		
		grid.add_child(button_container)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Choose a category to explore different game development techniques"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(instructions)
	
	return main_container

func _create_scene_selector_ui(category: String) -> Control:
	var category_info = available_categories[category]
	var main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Semi-transparent background
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.8)
	main_container.add_child(background)
	
	# Center panel container
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(center_container)
	
	# Main panel with adaptive sizing
	var panel = Panel.new()
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_width = min(max(viewport_size.x * 0.8, 400), 700)
	var panel_height = min(max(viewport_size.y * 0.7, 350), 500)
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center_container.add_child(panel)
	
	# Vertical layout with margins
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin_container.add_child(vbox)
	
	# Header with back button and title
	var header = HBoxContainer.new()
	vbox.add_child(header)
	
	var back_button = Button.new()
	back_button.text = "← Back to Categories"
	back_button.pressed.connect(_on_back_to_categories)
	header.add_child(back_button)
	
	header.add_child(Control.new())  # Spacer
	header.get_child(1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Title
	var title = Label.new()
	title.text = category_info.icon + " " + category_info.title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Scene buttons container
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll_container)
	
	var grid = GridContainer.new()
	grid.columns = 2 if panel_width > 500 else 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	scroll_container.add_child(grid)
	
	# Create buttons for each scene in the category
	for scene_key in category_info.scenes.keys():
		var scene_info = category_info.scenes[scene_key]
		var button_container = VBoxContainer.new()
		button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var button = Button.new()
		button.text = scene_info.title
		button.custom_minimum_size = Vector2(200, 50)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_scene_selected.bind(category, scene_key))
		button_container.add_child(button)
		
		var description = Label.new()
		description.text = scene_info.description
		description.custom_minimum_size = Vector2(200, 35)
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size", 11)
		button_container.add_child(description)
		
		grid.add_child(button_container)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Choose a scene to explore " + category_info.title.to_lower()
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(instructions)
	
	return main_container

func _on_category_selected(category_key: String):
	print("📂 Category selected: ", category_key)
	
	# Remove current selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	# Update URL if running in web
	if OS.has_feature("web"):
		var new_url = "window.location.href.split('?')[0] + '?category=" + category_key + "'"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
	
	# Show scene selector for this category
	current_category = category_key
	_show_scene_selector(category_key)

func _on_scene_selected(category: String, scene_key: String):
	print("🎯 Scene selected: ", category, "/", scene_key)
	
	# Remove selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	is_selector_active = false
	
	# Update URL if running in web
	if OS.has_feature("web"):
		var new_url = "window.location.href.split('?')[0] + '?category=" + category + "&scene=" + scene_key + "'"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
	
	# Load the selected scene
	_load_scene(category, scene_key)

func _on_back_to_categories():
	print("🔙 Back to categories")
	
	# Remove current selector UI
	if selector_ui:
		selector_ui.queue_free()
		selector_ui = null
	
	# Update URL if running in web
	if OS.has_feature("web"):
		var new_url = "window.location.href.split('?')[0]"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
	
	# Show category selector
	current_category = ""
	_show_category_selector()

func _load_scene(category: String, scene_key: String):
	if _is_valid_scene(category, scene_key):
		var scene_info = available_categories[category]["scenes"][scene_key]
		var scene_path = scene_info.path
		var scene = load(scene_path)
		if scene:
			var instance = scene.instantiate()
			add_child(instance)
			print("✅ Loaded scene: " + category + "/" + scene_key + " (" + scene_info.title + ")")
		else:
			print("❌ Failed to load scene: " + category + "/" + scene_key)
			print("⚠️ Scene file not found: " + scene_path)
			# Fallback to category selector
			_show_category_selector()
	else:
		print("❌ Invalid scene: " + category + "/" + scene_key)
		_show_category_selector()
