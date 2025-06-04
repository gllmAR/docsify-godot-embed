extends TutorialBase
class_name PhysicsDemoPlayer

# Base class for all physics demo players
# Provides physics-specific functionality for physics tutorials

func get_demo_category() -> String:
	return "physics"

# Physics-specific utility functions
func create_physics_display() -> VBoxContainer:
	var container = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "Physics Info:"
	title.add_theme_font_size_override("font_size", 14)
	container.add_child(title)
	
	return container

func create_force_display() -> Label:
	var display = Label.new()
	display.text = "Force: (0, 0)"
	return display

func update_force_display(display: Label, force: Vector2):
	display.text = "Force: (%.1f, %.1f)" % [force.x, force.y]
