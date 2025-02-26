extends CharacterBody2D

const SPEED = 300.0
const GRAVITY = 980.0
const NORMAL_JUMP_VELOCITY = -1000.0
const MIN_JUMP_VELOCITY = -550.0
const JUMP_HOLD_GRAVITY = 125.0
const JUMP_HOLD_TIME = 0.3

const POTION_JUMP_VELOCITY = -900.0  
const POTION_JUMP_HOLD_GRAVITY = 250.0  

var is_jumping = false
var jump_timer = 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("side-idle")

func _physics_process(delta: float) -> void:
	var potion_active = global.potion_active 

	
	if not is_on_floor():
		if is_jumping and Input.is_action_pressed("ui_up") and jump_timer < JUMP_HOLD_TIME:
			velocity.y += (POTION_JUMP_HOLD_GRAVITY if potion_active else JUMP_HOLD_GRAVITY) * delta
			jump_timer += delta
		else:
			velocity.y += GRAVITY * delta
	else:
	
		is_jumping = false
		jump_timer = 0.0  


	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = POTION_JUMP_VELOCITY if potion_active else MIN_JUMP_VELOCITY
		is_jumping = true
		jump_timer = 0.0  


	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("side-walk")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("side-idle")

	move_and_slide()
