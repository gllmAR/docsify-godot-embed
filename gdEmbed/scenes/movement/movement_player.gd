extends TutorialBase
class_name MovementDemoPlayer

# Base class for all movement demo players
# Provides movement-specific functionality for movement tutorials

func get_demo_category() -> String:
	return "movement"

# Movement-specific utility functions
func create_velocity_display() -> Label:
	var display = Label.new()
	display.text = "Velocity: (0, 0)"
	return display

func update_velocity_display(display: Label, velocity: Vector2):
	display.text = "Velocity: (%.1f, %.1f)" % [velocity.x, velocity.y]

func create_position_display() -> Label:
	var display = Label.new()
	display.text = "Position: (0, 0)"
	return display

func update_position_display(display: Label, position: Vector2):
	display.text = "Position: (%.1f, %.1f)" % [position.x, position.y]
