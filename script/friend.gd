extends CharacterBody2D
var speed: float = 60.0
var acceleration: float = 200.0
var stop_distance: float = 50.0
var follow_offset: float = 40.0
var max_speed: float = 80.0
var dampening: float = 0.92



@onready var player_chase: bool = false
@onready var player1: Node2D = null
@onready var current_velocity: Vector2 = Vector2.ZERO
@onready var last_player_pos: Vector2 = Vector2.ZERO

@onready var cutscene_timer: float = 0.0
var cutscene_duration: float = 55.0
var is_in_cutscene: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("front-idle")

	var err = GlobalSignals.connect("player_entered_car", on_player_near_car)
	if err != OK:
		print("Error connecting signal: sigma", err)


func _physics_process(delta: float) -> void:
	
	if is_in_cutscene:
		cutscene_timer += delta
		if cutscene_timer >= cutscene_duration:
			is_in_cutscene = false 
			global.friend_interaction_friend_pause = 1
		return

	if player_chase and player1:
	
		var to_target = player1.global_position - global_position
		var distance = to_target.length()
		var raw_direction = to_target.normalized()

		if raw_direction.y < 0 and abs(raw_direction.y) > abs(raw_direction.x):
			raw_direction.x = 0
			raw_direction = raw_direction.normalized()
		

		var move_direction = raw_direction
		
		if distance <= stop_distance:
	
			current_velocity = current_velocity.move_toward(Vector2.ZERO, acceleration * delta)
			_face_player()
		else:

			var target_speed = speed
			if distance < stop_distance * 2:
				target_speed *= (distance - stop_distance) / stop_distance
			
			var desired_velocity = move_direction * min(target_speed, max_speed)
			current_velocity = current_velocity.move_toward(desired_velocity, acceleration * delta)

		if current_velocity.length() > 1.0:
			velocity = current_velocity
			move_and_slide()
			_update_animation(current_velocity.normalized())
		else:
			velocity = Vector2.ZERO
			_face_player()
			
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, acceleration * delta)
		velocity = current_velocity
		move_and_slide()
		if current_velocity.length() < 1.0:
			$AnimatedSprite2D.play("front-idle")

func _face_player() -> void:
	if player1:
		var to_player = player1.global_position - global_position
		var normalized_direction = to_player.normalized()
		

		if abs(normalized_direction.y) >= abs(normalized_direction.x):
			if normalized_direction.y < 0:  
				$AnimatedSprite2D.play("back-walk")
			else:  
				$AnimatedSprite2D.play("front-idle")
		else:  
			$AnimatedSprite2D.play("side-walk")
			$AnimatedSprite2D.flip_h = normalized_direction.x < 0

func _update_animation(direction: Vector2) -> void:
	
	if abs(direction.y) >= abs(direction.x):
		if direction.y < 0:  
			$AnimatedSprite2D.play("back-walk")
		else: 
			$AnimatedSprite2D.play("front-walk")
	else:  
		$AnimatedSprite2D.play("side-walk")
		$AnimatedSprite2D.flip_h = direction.x < 0

func _on_detection_body_entered(body: Node2D) -> void:
	player1 = body
	player_chase = true
	current_velocity = Vector2.ZERO
	
	if global.friend_interaction_friend_pause == 0:
		cutscene_timer = 0.0
		is_in_cutscene = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player1:
		player1 = null
		player_chase = false
 
func on_player_near_car():
	print("vanishing friend!")
	print("signals found")
	velocity = Vector2.ZERO
	move_and_slide()
	visible = false
	return
	
