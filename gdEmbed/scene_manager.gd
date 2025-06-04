extends Node2D

var available_scenes = {
	"movement": {
		"path": "res://scenes/movement/movement.tscn",
		"title": "Movement Techniques",
		"description": "Learn different movement techniques in game development"
	},
	"animation": {
		"path": "res://scenes/animation/animation.tscn", 
		"title": "Animation Systems",
		"description": "Learn animation techniques for dynamic visual feedback"
	},
	"physics": {
		"path": "res://scenes/physics/physics.tscn",
		"title": "Physics Simulation",
		"description": "Explore physics-based interactions and simulations"
	},
	"input": {
		"path": "res://scenes/input/input.tscn",
		"title": "Input Handling",
		"description": "Master different input methods and player controls"
	}
}

var scene_selector_ui: Control
var is_selector_active = false

func _ready():
	var scene_name = _parse_scene_parameter()
	if scene_name == "":
		_show_scene_selector()
	else:
		_load_scene(scene_name)

func _parse_scene_parameter() -> String:
	if OS.has_feature("web"):
		# Simple and reliable URL parameter parsing
		var scene_result = JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('scene')")
		print("🎮 Scene parameter from URL: ", scene_result)
		
		if scene_result and scene_result != "" and available_scenes.has(scene_result):
			print("✅ Loading scene: ", scene_result)
			return scene_result
		else:
			print("ℹ️ No valid scene parameter found, showing selector")
			return ""
	
	return ""

func _show_scene_selector():
	is_selector_active = true
	scene_selector_ui = _create_scene_selector_ui()
	add_child(scene_selector_ui)

func _create_scene_selector_ui() -> Control:
	var main_container = Control.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Semi-transparent background
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.8)
	main_container.add_child(background)
	
	# Center panel container for responsive centering
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(center_container)
	
	# Main panel with adaptive sizing
	var panel = Panel.new()
	# Adaptive size based on screen size (80% width, max 700px, min 400px)
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
	title.text = "🎮 Select a Demo Scene"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Scene buttons container - responsive grid
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll_container)
	
	var grid = GridContainer.new()
	# Adaptive columns based on panel width
	grid.columns = 2 if panel_width > 500 else 1
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	scroll_container.add_child(grid)
	
	# Create buttons for each scene
	for scene_key in available_scenes.keys():
		var scene_info = available_scenes[scene_key]
		var button_container = VBoxContainer.new()
		button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var button = Button.new()
		button.text = scene_info.title
		button.custom_minimum_size = Vector2(200, 50)  # Smaller for mobile
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_scene_selected.bind(scene_key))
		button_container.add_child(button)
		
		var description = Label.new()
		description.text = scene_info.description
		description.custom_minimum_size = Vector2(200, 35)  # Smaller for mobile
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.add_theme_font_size_override("font_size", 11)
		button_container.add_child(description)
		
		grid.add_child(button_container)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Choose a scene to explore different game development techniques"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(instructions)
	
	return main_container

func _on_scene_selected(scene_key: String):
	print("🎯 Scene selected: ", scene_key)
	
	# Remove the selector UI
	if scene_selector_ui:
		scene_selector_ui.queue_free()
		scene_selector_ui = null
	
	is_selector_active = false
	
	# Update URL if running in web
	if OS.has_feature("web"):
		var new_url = "window.location.href.split('?')[0] + '?scene=" + scene_key + "'"
		JavaScriptBridge.eval("window.history.pushState({}, '', " + new_url + ")")
	
	# Load the selected scene
	_load_scene(scene_key)

func _load_scene(scene_name: String):
	if available_scenes.has(scene_name):
		var scene_info = available_scenes[scene_name]
		var scene_path = scene_info.path
		var scene = load(scene_path)
		if scene:
			var instance = scene.instantiate()
			add_child(instance)
			print("✅ Loaded scene: " + scene_name + " (" + scene_info.title + ")")
		else:
			print("❌ Failed to load scene: " + scene_name)
	else:
		print("❌ Unknown scene: " + scene_name)
