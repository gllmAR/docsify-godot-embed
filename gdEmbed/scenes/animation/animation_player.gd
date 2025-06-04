extends TutorialBase
class_name AnimationDemoPlayer

# Base class for all animation demo players
# Provides animation-specific functionality for animation tutorials

func get_demo_category() -> String:
	return "animation"

# Animation-specific utility functions
func create_animation_node() -> AnimationPlayer:
	var anim_player = AnimationPlayer.new()
	add_child(anim_player)
	return anim_player

func create_tween() -> Tween:
	var tween = create_tween()
	return tween
