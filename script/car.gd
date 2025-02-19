extends CharacterBody2D
var input_blocked = true

@export var acceleration: float = 800.0       
@export var friction: float = 500.0           
@export var brake_friction: float = 1500.0      
@export var max_speed: float = 300.0           
@export var max_reverse_speed: float = 150.0   
@export var turn_speed: float = 2.0            
@export var drift_factor: float = 0.9         
func _physics_process(delta: float) -> void:
	if input_blocked:
		velocity = Vector2.ZERO
		move_and_slide()
		return  
	var forward: Vector2 = Vector2(cos(rotation), sin(rotation))
	

	if Input.is_action_pressed("brake"):
		var speed = velocity.length()
		if speed > 0:
			var decel = brake_friction * delta
			if decel > speed:
				velocity = Vector2.ZERO
			else:
				velocity = velocity.normalized() * (speed - decel)
				

	elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):

		var input_direction: float = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")

		velocity += forward * input_direction * acceleration * delta
		

		var steering: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		if input_direction < 0:
			steering = -steering

		var speed_factor: float = clamp(velocity.length() / max_speed, 0.3, 1.0)

		if velocity.length() > 20:
			rotation += steering * turn_speed * delta * speed_factor

	else:
		var speed = velocity.length()
		if speed > 0:
			var decel = friction * delta
			if decel > speed:
				velocity = Vector2.ZERO
			else:
				velocity = velocity.normalized() * (speed - decel)

	var forward_speed: float = velocity.dot(forward)
	if forward_speed > max_speed:
		velocity = forward * max_speed + (velocity - forward * forward_speed)
	elif forward_speed < -max_reverse_speed:
		velocity = forward * -max_reverse_speed + (velocity - forward * forward_speed)
	

	var lateral_velocity: Vector2 = velocity - forward * velocity.dot(forward)
	velocity = forward * velocity.dot(forward) + lateral_velocity * drift_factor
	
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	input_blocked = false
