extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const FOLLOW_DISTANCE = 100.0  
const STOP_DISTANCE = 150.0    
const JUMP_FORWARD_SPEED = 500.0
const MAX_GAP_JUMP = 150.0


var target = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var pause_timer = 0.0
var is_paused = false
var current_animation = "side-idle"
var rng = RandomNumberGenerator.new()
var jump_cooldown = 0.0


@onready var ground_check = $GroundRaycast
@onready var wall_check = $WallRaycast
@onready var gap_check = $GapRaycast
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	rng.randomize()
	animated_sprite.play("side-idle")
	current_animation = "side-idle"
	
	
	ground_check.target_position = Vector2(25, 20)
	wall_check.target_position = Vector2(25, 0)
	gap_check.position.x = 20
	gap_check.target_position = Vector2(0, 50)

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if jump_cooldown > 0:
		jump_cooldown -= delta
	
	
	if is_paused:
		pause_timer -= delta
		if pause_timer <= 0:
			is_paused = false
	
	
	if target and !is_paused:
		var distance = target.global_position.x - global_position.x
		var direction_x = sign(distance)
		
		
		animated_sprite.flip_h = direction_x < 0
		
		
		ground_check.target_position.x = 25 * direction_x
		wall_check.target_position.x = 25 * direction_x
		gap_check.position.x = 20 * direction_x
		
	
		var ledge_ahead = not ground_check.is_colliding() and is_on_floor()
		var obstacle_ahead = wall_check.is_colliding()
		
		
		var gap_size = measure_gap(direction_x)
		
		
		if is_on_floor() and jump_cooldown <= 0:
			if obstacle_ahead:
				jump(direction_x, 100) 
			elif ledge_ahead and gap_size < MAX_GAP_JUMP:
				jump(direction_x, gap_size) 
		
		
		if abs(distance) > FOLLOW_DISTANCE:
			velocity.x = direction_x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

	if not is_on_floor():
		set_animation("side-walk")
	elif abs(velocity.x) > 10:
		set_animation("side-walk")
	else:
		set_animation("side-idle")
	
	move_and_slide()

func measure_gap(direction: float) -> float:

	gap_check.position.x = 20 * direction
	gap_check.enabled = true
	

	if gap_check.is_colliding():
		return 0.0

	var gap_width = 0.0
	var test_position = gap_check.global_position
	var max_iterations = 30 
	var iterations = 0
	
	while iterations < max_iterations:
		iterations += 1
		test_position.x += 10 * direction
		
	
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(
			test_position,
			test_position + Vector2(0, 50)
		)
		var result = space_state.intersect_ray(query)
		
		if result:
			
			gap_width = abs(test_position.x - gap_check.global_position.x)
			break
		
		if gap_width > MAX_GAP_JUMP * 1.5:
	
			break
	
	return gap_width

func jump(direction_x: float, gap_size: float) -> void:
	if is_on_floor():

		var jump_power = JUMP_VELOCITY
		var horizontal_boost = SPEED + min(gap_size * 3.5, JUMP_FORWARD_SPEED)
		
		velocity.y = jump_power
		velocity.x = direction_x * horizontal_boost

		jump_cooldown = 0.5
		print(gap_size)
	
		set_animation("side-walk")

func set_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		current_animation = anim_name
		animated_sprite.play(anim_name)

func _on_detection_body_entered(body: Node2D) -> void:
	if body != self:  
		target = body
		print("player entered: following " + body.name)

func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("target exited: stopping")

func pause_movement(duration: float = 1.0) -> void:
	is_paused = true
	pause_timer = duration
