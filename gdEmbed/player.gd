extends CharacterBody2D

@export var speed: float = 200.0
@export var movement_type: int = 1  # 1=Direct, 2=Velocity, 3=Interpolated

var target_position: Vector2
var movement_types = ["Direct", "Velocity", "Interpolated"]
var demo_mode: String = "movement"  # Default demo mode
var time_counter: float = 0.0  # Internal timer for animations
var available_demos = {
	"movement": "Movement Demo",
	"animation": "Animation Demo", 
	"physics": "Physics Demo",
	"input": "Input System Demo"
}

func _ready():
	target_position = position
	
	# Parse URL parameters to determine demo mode
	_parse_demo_parameters()
	
	# Initialize the appropriate demo
	_initialize_demo()
	
	print(available_demos[demo_mode] + " Ready!")

func _parse_demo_parameters():
	# In Godot web builds, we can access URL parameters through JavaScript
	if OS.has_feature("web"):
		var js_code = """
		(function() {
			var urlParams = new URLSearchParams(window.location.search);
			// Check for both 'scene' and 'demo' parameters for backward compatibility
			return urlParams.get('scene') || urlParams.get('demo') || 'movement';
		})()
		"""
		var result = JavaScriptBridge.eval(js_code)
		if result and available_demos.has(result):
			demo_mode = result
			print("Demo mode set to: " + demo_mode + " (from URL parameter)")
		else:
			demo_mode = "movement"  # fallback
			print("Demo mode fallback to: " + demo_mode)
	else:
		demo_mode = "movement"  # fallback for non-web builds

func _initialize_demo():
	# Configure the scene based on demo mode
	match demo_mode:
		"movement":
			_setup_movement_demo()
		"animation":
			_setup_animation_demo()
		"physics":
			_setup_physics_demo()
		"input":
			_setup_input_demo()
		_:
			_setup_movement_demo()  # fallback

func _setup_movement_demo():
	# Current movement demo setup
	print("Movement Demo Ready - Use arrow keys to move, 1-3 to change movement type")

func _setup_animation_demo():
	print("Animation Demo - Interactive animations and effects!")
	modulate = Color.BLUE
	# Enable animation-specific features
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	
func _setup_physics_demo():
	print("Physics Demo - Realistic movement with momentum!")
	modulate = Color.RED
	# Initialize physics properties
	velocity = Vector2.ZERO
	
func _setup_input_demo():
	print("Input Demo - Advanced input handling techniques!")
	modulate = Color.GREEN
	# Set up input sensitivity

func _process(_delta):
	# Only show movement controls for movement demo
	if demo_mode == "movement":
		_handle_movement_demo_ui()
	else:
		_handle_other_demo_ui()

func _handle_movement_demo_ui():
	# Display current movement type
	var ui_node = get_node_or_null("../UI/MovementTypeLabel")
	if ui_node:
		ui_node.text = "Movement Type: " + movement_types[movement_type - 1]
	
	# Handle input for movement type switching
	if Input.is_action_just_pressed("ui_1"):
		movement_type = 1
	elif Input.is_action_just_pressed("ui_2"):
		movement_type = 2
	elif Input.is_action_just_pressed("ui_3"):
		movement_type = 3
	elif Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		target_position = position

func _handle_other_demo_ui():
	# Display demo type for other demos
	var ui_node = get_node_or_null("../UI/MovementTypeLabel")
	if ui_node:
		ui_node.text = available_demos[demo_mode]
	
	# Reset position for other demos
	if Input.is_action_just_pressed("ui_reset"):
		position = Vector2(400, 300)
		target_position = position

func _physics_process(delta):
	time_counter += delta  # Update our internal timer
	
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()
	
	# Handle movement based on demo mode
	match demo_mode:
		"movement":
			_handle_movement_demo(input_vector, delta)
		"animation":
			_handle_animation_demo(input_vector, delta)
		"physics":
			_handle_physics_demo(input_vector, delta)
		"input":
			_handle_input_demo(input_vector, delta)
		_:
			_handle_movement_demo(input_vector, delta)  # fallback
	
	# Keep within screen bounds
	position.x = clamp(position.x, 50, 750)
	position.y = clamp(position.y, 50, 550)

func _handle_movement_demo(input_vector: Vector2, delta: float):
	match movement_type:
		1:  # Direct movement
			_direct_movement(input_vector, delta)
		2:  # Velocity-based movement
			_velocity_movement(input_vector)
		3:  # Interpolated movement
			_interpolated_movement(input_vector, delta)

func _handle_animation_demo(input_vector: Vector2, delta: float):
	# Advanced animated movement for animation demo
	if input_vector != Vector2.ZERO:
		# Add smooth rotation while moving
		var target_rotation = input_vector.angle() + PI/2
		rotation = lerp_angle(rotation, target_rotation, delta * 8.0)
		
		# Bouncy movement with scale animation
		var move_scale = 1.0 + sin(time_counter * 10.0) * 0.1
		scale = Vector2(move_scale, move_scale)
		
		# Trail effect - change color while moving
		var hue = fmod(time_counter * 0.5, 1.0)
		modulate = Color.from_hsv(hue, 0.8, 1.0)
		
		velocity = input_vector * speed
		move_and_slide()
	else:
		# Return to neutral state when not moving
		rotation = lerp_angle(rotation, 0.0, delta * 5.0)
		scale = scale.lerp(Vector2.ONE, delta * 5.0)
		modulate = modulate.lerp(Color.BLUE, delta * 2.0)

func _handle_physics_demo(input_vector: Vector2, delta: float):
	# Advanced physics-based movement with realistic momentum and friction
	var acceleration = 800.0
	var friction = 600.0
	var max_speed = speed * 1.2
	
	if input_vector != Vector2.ZERO:
		# Apply acceleration in input direction
		velocity += input_vector * acceleration * delta
		
		# Add slight sliding effect - reduce control when moving fast
		var speed_factor = 1.0 - (velocity.length() / max_speed) * 0.3
		velocity = velocity.move_toward(input_vector * velocity.length(), acceleration * delta * speed_factor)
		
		# Visual feedback for speed
		var speed_intensity = clamp(velocity.length() / max_speed, 0.3, 1.0)
		modulate = Color.RED.lerp(Color.ORANGE, speed_intensity)
		
		# Add slight rotation based on velocity direction
		if velocity.length() > 50:
			var target_rotation = velocity.angle() + PI/2
			rotation = lerp_angle(rotation, target_rotation, delta * 3.0)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# Return to neutral visuals
		modulate = modulate.lerp(Color.RED, delta * 3.0)
		rotation = lerp_angle(rotation, 0.0, delta * 2.0)
	
	# Limit maximum speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	move_and_slide()
	
	# Add bounce effect when hitting walls
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var bounce_factor = 0.3
		velocity = velocity.bounce(collision.get_normal()) * bounce_factor
		
		# Visual feedback for collision
		modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.2)

func _handle_input_demo(input_vector: Vector2, delta: float):
	# Advanced input demonstration with different response curves
	
	# Show different input processing techniques
	var processed_input = Vector2.ZERO
	
	# Non-linear input response (more sensitive at edges)
	if input_vector != Vector2.ZERO:
		var magnitude = input_vector.length()
		var direction = input_vector.normalized()
		
		# Apply curve to magnitude (quadratic for more dramatic effect)
		var curved_magnitude = magnitude * magnitude
		processed_input = direction * curved_magnitude
		
		# Visual feedback showing input intensity
		var intensity = clamp(curved_magnitude, 0.1, 1.0)
		modulate = Color.GREEN.lerp(Color.YELLOW, intensity)
		
		# Scale character based on input intensity
		var target_scale = 1.0 + intensity * 0.5
		scale = scale.lerp(Vector2(target_scale, target_scale), delta * 8.0)
		
		# Apply processed movement
		velocity = processed_input * speed * 1.5
		move_and_slide()
		
		# Add input trail effect
		rotation += delta * magnitude * 5.0
	else:
		# Return to neutral state
		modulate = modulate.lerp(Color.GREEN, delta * 4.0)
		scale = scale.lerp(Vector2.ONE, delta * 6.0)
		rotation = lerp_angle(rotation, 0.0, delta * 3.0)
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 4.0)
		move_and_slide()
	
	# Demonstrate input buffering effect
	if Input.is_action_just_pressed("ui_reset"):
		# Quick dash effect on reset
		var dash_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		position += dash_direction * 100
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _direct_movement(input_vector: Vector2, delta: float):
	if input_vector != Vector2.ZERO:
		position += input_vector * speed * delta

func _velocity_movement(input_vector: Vector2):
	velocity = input_vector * speed
	move_and_slide()

func _interpolated_movement(input_vector: Vector2, delta: float):
	if input_vector != Vector2.ZERO:
		target_position += input_vector * speed * delta
	
	# Smooth interpolation to target
	position = position.lerp(target_position, 5.0 * delta)
	
	# Keep target within bounds too
	target_position.x = clamp(target_position.x, 50, 750)
	target_position.y = clamp(target_position.y, 50, 550)
