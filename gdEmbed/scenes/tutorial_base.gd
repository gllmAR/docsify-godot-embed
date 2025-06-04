extends Node
class_name TutorialBase

# Universal base class for all tutorial demos
# Provides common navigation and UI functionality across all categories

@onready var ui_container = get_node("UIContainer")
@onready var demo_area = get_node("DemoArea")

var current_category: String = ""
var current_demo: String = ""

func _ready():
	setup_common_ui()
	setup_demo_specific()

func setup_common_ui():
	# Create common UI elements that all demos share
	if not ui_container:
		ui_container = VBoxContainer.new()
		ui_container.name = "UIContainer"
		add_child(ui_container)
	
	# Add navigation bar at the top
	create_navigation_bar()
	
	# Add title
	var title_label = Label.new()
	title_label.text = get_demo_title()
	title_label.add_theme_font_size_override("font_size", 24)
	ui_container.add_child(title_label)
	
	# Add description
	var desc_label = Label.new()
	desc_label.text = get_demo_description()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_container.add_child(desc_label)
	
	# Add separator
	var separator = HSeparator.new()
	ui_container.add_child(separator)

func setup_demo_specific():
	# Override this in child classes
	pass

func create_navigation_bar():
	# Create simple back button only
	var back_button = create_button("← Back to " + get_demo_category().capitalize(), _on_back_to_category)
	back_button.custom_minimum_size = Vector2(100, 25)
	back_button.add_theme_font_size_override("font_size", 12)
	ui_container.add_child(back_button)

func get_demo_title() -> String:
	# Override this in child classes
	return "Tutorial Demo"

func get_demo_description() -> String:
	# Override this in child classes
	return "Interactive tutorial demonstration."

func get_demo_category() -> String:
	# Override this in child classes
	return "general"

# Utility functions for demos
func create_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.pressed.connect(callback)
	return button

func create_slider(min_val: float, max_val: float, initial_val: float, callback: Callable) -> HSlider:
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = initial_val
	slider.value_changed.connect(callback)
	return slider

func create_labeled_slider(label_text: String, min_val: float, max_val: float, initial_val: float, callback: Callable) -> VBoxContainer:
	var container = VBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	container.add_child(label)
	
	var slider = create_slider(min_val, max_val, initial_val, callback)
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(initial_val)
	container.add_child(value_label)
	
	# Update value label when slider changes
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
	return container

# Navigation functions
func _on_back_to_manager():
	# Navigate back to the scene manager
	var scene_manager = get_node("/root/SceneManager")
	if scene_manager and scene_manager.has_method("load_scene"):
		scene_manager.load_scene("scene_manager")
	else:
		print("Navigating back to scene manager...")
		# Fallback: try to reload the main scene
		get_tree().change_scene_to_file("res://main.tscn")

func _on_back_to_category():
	# Navigate back to the category listing page
	var category = get_demo_category()
	print("Navigating back to ", category, " category")
	# This would navigate to a category overview page if it exists
	# For now, just go to the first demo in the category
	var first_demo = get_first_demo_in_category(category)
	if first_demo:
		_on_navigate_to_demo(first_demo)
	else:
		_on_back_to_manager()

func _on_navigate_to_category(category: String):
	# Navigate to first demo in the specified category
	var scene_manager = get_node("/root/SceneManager")
	if scene_manager and scene_manager.has_method("load_scene"):
		var first_demo = get_first_demo_in_category(category)
		if first_demo:
			scene_manager.load_scene(first_demo)
		else:
			print("No demos found in category: ", category)
	else:
		print("Navigating to category: ", category)

func _on_navigate_to_demo(demo_scene: String):
	# Navigate to another demo
	var scene_manager = get_node("/root/SceneManager")
	if scene_manager and scene_manager.has_method("load_scene"):
		scene_manager.load_scene(demo_scene)
	else:
		print("Navigating to demo: ", demo_scene)
		# Fallback: construct scene path and load directly
		var category = get_demo_category()
		var scene_path = "res://scenes/" + category + "/" + demo_scene + "/" + demo_scene + ".tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Scene not found: ", scene_path)

func get_first_demo_in_category(category: String) -> String:
	# Use SceneManagerGlobal to get the first demo in a category
	# Handle case where autoload might not be immediately available
	var scene_manager_global = get_node_or_null("/root/SceneManagerGlobal")
	if scene_manager_global and scene_manager_global.has_method("get_first_demo_in_category"):
		return scene_manager_global.get_first_demo_in_category(category)
	else:
		print("SceneManagerGlobal not available, using fallback")
		return ""
