extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FOLLOW_DISTANCE = 100.0  
const STOP_DISTANCE = 150.0    

var target = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var pause_timer = 0.0
var is_paused = false
var current_animation = "side-idle"


var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	$AnimatedSprite2D.play("side-idle")
	current_animation = "side-idle"

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += gravity * delta
	

	if is_paused:
		pause_timer -= delta
		if pause_timer <= 0:
			is_paused = false
	

	if target and !is_paused:
		var distance = abs(target.global_position.x - global_position.x)
		

		if abs(velocity.x) < 10 and rng.randf() < 0.01:  
			is_paused = true
			pause_timer = rng.randf_range(0.5, 1.0) 
			set_animation("side-idle")
			velocity.x = 0
		
		elif distance > FOLLOW_DISTANCE and distance < STOP_DISTANCE:
			var direction_x = sign(target.global_position.x - global_position.x)
			velocity.x = direction_x * SPEED
			set_animation("side-walk")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			set_animation("side-idle")
	else:
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		set_animation("side-idle")
	
	move_and_slide()


func set_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		current_animation = anim_name
		$AnimatedSprite2D.play(anim_name)

func _on_detection_body_entered(body: Node2D) -> void:
	if body != self:
		target = body
		print("player entered: following " + body.name)

func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("target exited: stopping")
