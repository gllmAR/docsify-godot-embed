extends TutorialBase
class_name InputDemoPlayer

# Base class for all input demo players
# Provides input-specific functionality for input tutorials

func get_demo_category() -> String:
	return "input"

# Input-specific utility functions
func create_input_display(action_name: String) -> Label:
	var display = Label.new()
	display.text = action_name + ": Not Pressed"
	return display

func update_input_display(display: Label, action_name: String, is_pressed: bool):
	var status = "Pressed" if is_pressed else "Not Pressed"
	display.text = action_name + ": " + status
	display.add_theme_color_override("font_color", Color.GREEN if is_pressed else Color.WHITE)
