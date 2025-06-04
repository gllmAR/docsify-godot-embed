extends Node2D

@onready var ui = $UI
@onready var gravity_slider = $UI/ParameterPanel/VBoxContainer/GravityContainer/GravitySlider
@onready var gravity_label = $UI/ParameterPanel/VBoxContainer/GravityContainer/GravityLabel
@onready var friction_slider = $UI/ParameterPanel/VBoxContainer/FrictionContainer/FrictionSlider
@onready var friction_label = $UI/ParameterPanel/VBoxContainer/FrictionContainer/FrictionLabel
@onready var force_slider = $UI/ParameterPanel/VBoxContainer/ForceContainer/ForceSlider
@onready var force_label = $UI/ParameterPanel/VBoxContainer/ForceContainer/ForceLabel
@onready var velocity_label = $UI/StatusPanel/VBoxContainer/VelocityLabel
@onready var acceleration_label = $UI/StatusPanel/VBoxContainer/AccelerationLabel
@onready var energy_label = $UI/StatusPanel/VBoxContainer/EnergyLabel

var physics_objects = []
var gravity_strength = 500.0
var air_friction = 0.98
var applied_force = 200.0

# Physics object class
class PhysicsObject:
	var position: Vector2
	var velocity: Vector2
	var acceleration: Vector2
	var mass: float
	var color: Color
	var radius: float
	var is_bouncy: bool
	var restitution: float  # Bounciness factor
	
	func _init(pos: Vector2, m: float = 1.0, c: Color = Color.WHITE, r: float = 20.0):
		position = pos
		velocity = Vector2.ZERO
		acceleration = Vector2.ZERO
		mass = m
		color = c
		radius = r
		is_bouncy = true
		restitution = 0.8

func _ready():
	_setup_ui()
	_create_physics_objects()

func _setup_ui():
	gravity_slider.value = gravity_strength
	gravity_slider.value_changed.connect(_on_gravity_changed)
	
	friction_slider.value = air_friction * 100
	friction_slider.value_changed.connect(_on_friction_changed)
	
	force_slider.value = applied_force
	force_slider.value_changed.connect(_on_force_changed)
	
	_update_labels()

func _create_physics_objects():
	# Create different physics objects with varying properties
	var objects_data = [
		{"pos": Vector2(150, 100), "mass": 1.0, "color": Color.RED, "radius": 15},
		{"pos": Vector2(300, 100), "mass": 2.0, "color": Color.GREEN, "radius": 20},
		{"pos": Vector2(450, 100), "mass": 0.5, "color": Color.BLUE, "radius": 12},
		{"pos": Vector2(600, 100), "mass": 3.0, "color": Color.YELLOW, "radius": 25}
	]
	
	for data in objects_data:
		var obj = PhysicsObject.new(data.pos, data.mass, data.color, data.radius)
		physics_objects.append(obj)

func _process(delta):
	_update_physics(delta)
	_handle_input()
	_update_ui()
	queue_redraw()

func _update_physics(delta):
	var screen_size = get_viewport().get_visible_rect().size
	
	for obj in physics_objects:
		# Reset acceleration
		obj.acceleration = Vector2.ZERO
		
		# Apply gravity
		obj.acceleration.y += gravity_strength / obj.mass
		
		# Apply input force to first object
		if obj == physics_objects[0]:
			var input_force = Vector2.ZERO
			if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
				input_force.x -= applied_force
			if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
				input_force.x += applied_force
			if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
				input_force.y -= applied_force
			
			obj.acceleration += input_force / obj.mass
		
		# Update velocity based on acceleration
		obj.velocity += obj.acceleration * delta
		
		# Apply air friction
		obj.velocity *= air_friction
		
		# Update position based on velocity
		obj.position += obj.velocity * delta
		
		# Boundary collisions with bounce
		if obj.position.x - obj.radius <= 0:
			obj.position.x = obj.radius
			obj.velocity.x *= -obj.restitution
		elif obj.position.x + obj.radius >= screen_size.x:
			obj.position.x = screen_size.x - obj.radius
			obj.velocity.x *= -obj.restitution
		
		if obj.position.y - obj.radius <= 0:
			obj.position.y = obj.radius
			obj.velocity.y *= -obj.restitution
		elif obj.position.y + obj.radius >= screen_size.y:
			obj.position.y = screen_size.y - obj.radius
			obj.velocity.y *= -obj.restitution
		
		# Object-to-object collisions
		for other_obj in physics_objects:
			if other_obj != obj:
				_handle_collision(obj, other_obj)

func _handle_collision(obj1: PhysicsObject, obj2: PhysicsObject):
	var distance = obj1.position.distance_to(obj2.position)
	var min_distance = obj1.radius + obj2.radius
	
	if distance < min_distance and distance > 0:
		# Collision detected - simple elastic collision
		var collision_normal = (obj2.position - obj1.position) / distance
		var relative_velocity = obj1.velocity - obj2.velocity
		var velocity_along_normal = relative_velocity.dot(collision_normal)
		
		# Don't resolve if velocities are separating
		if velocity_along_normal > 0:
			return
		
		# Calculate restitution
		var e = min(obj1.restitution, obj2.restitution)
		
		# Calculate impulse scalar
		var j = -(1 + e) * velocity_along_normal
		j /= 1/obj1.mass + 1/obj2.mass
		
		# Apply impulse
		var impulse = j * collision_normal
		obj1.velocity += impulse / obj1.mass
		obj2.velocity -= impulse / obj2.mass
		
		# Separate objects to prevent overlap
		var separation = (min_distance - distance) / 2
		obj1.position -= collision_normal * separation
		obj2.position += collision_normal * separation

func _handle_input():
	# Reset all objects when R is pressed
	if Input.is_action_just_pressed("ui_select") or Input.is_key_pressed(KEY_R):
		_reset_objects()

func _reset_objects():
	var positions = [
		Vector2(150, 100),
		Vector2(300, 100), 
		Vector2(450, 100),
		Vector2(600, 100)
	]
	
	for i in range(physics_objects.size()):
		physics_objects[i].position = positions[i]
		physics_objects[i].velocity = Vector2.ZERO
		physics_objects[i].acceleration = Vector2.ZERO

func _update_ui():
	if physics_objects.size() > 0:
		var obj = physics_objects[0]  # Display stats for first object
		velocity_label.text = "Velocity: (%.1f, %.1f) | Speed: %.1f px/s" % [
			obj.velocity.x, obj.velocity.y, obj.velocity.length()
		]
		acceleration_label.text = "Acceleration: (%.1f, %.1f) | Magnitude: %.1f px/s²" % [
			obj.acceleration.x, obj.acceleration.y, obj.acceleration.length()
		]
		
		# Calculate kinetic energy (KE = 0.5 * m * v²)
		var kinetic_energy = 0.5 * obj.mass * obj.velocity.length_squared()
		energy_label.text = "Kinetic Energy: %.1f | Mass: %.1f kg" % [kinetic_energy, obj.mass]

func _draw():
	# Draw physics objects
	for obj in physics_objects:
		draw_circle(obj.position, obj.radius, obj.color)
		draw_circle(obj.position, obj.radius, Color.WHITE, false, 2.0)
		
		# Draw velocity vector
		if obj.velocity.length() > 5:
			var vel_end = obj.position + obj.velocity * 0.1
			draw_line(obj.position, vel_end, Color.CYAN, 3.0)
			_draw_arrow_head(obj.position, vel_end, Color.CYAN)
		
		# Draw acceleration vector
		if obj.acceleration.length() > 10:
			var acc_end = obj.position + obj.acceleration * 0.05
			draw_line(obj.position, acc_end, Color.ORANGE, 2.0)
			_draw_arrow_head(obj.position, acc_end, Color.ORANGE)
	
	# Draw force indicators
	if physics_objects.size() > 0:
		var obj = physics_objects[0]
		_draw_force_indicators(obj)

func _draw_arrow_head(start: Vector2, end: Vector2, color: Color):
	var direction = (end - start).normalized()
	var arrow_size = 8
	var arrow1 = end - direction * arrow_size + direction.rotated(PI/2) * arrow_size * 0.5
	var arrow2 = end - direction * arrow_size - direction.rotated(PI/2) * arrow_size * 0.5
	
	draw_line(end, arrow1, color, 2.0)
	draw_line(end, arrow2, color, 2.0)

func _draw_force_indicators(obj: PhysicsObject):
	# Show applied forces as indicators
	var force_scale = 0.2
	
	# Gravity force
	var gravity_force = Vector2(0, gravity_strength) * force_scale
	var gravity_end = obj.position + gravity_force
	draw_line(obj.position, gravity_end, Color.PURPLE, 2.0)
	_draw_arrow_head(obj.position, gravity_end, Color.PURPLE)

func _on_gravity_changed(value):
	gravity_strength = value
	_update_labels()

func _on_friction_changed(value):
	air_friction = value / 100.0
	_update_labels()

func _on_force_changed(value):
	applied_force = value
	_update_labels()

func _update_labels():
	gravity_label.text = "Gravity: %.0f px/s²" % gravity_strength
	friction_label.text = "Air Friction: %.1f%%" % (air_friction * 100)
	force_label.text = "Applied Force: %.0f N" % applied_force
