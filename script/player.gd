extends CharacterBody2D
class_name player
const speed = 100
var current_dir: String = "none"


func _ready():
	$AnimatedSprite2D.play("front-idle")
	print("Player ready!")
	# Print collision info
	print("Player collision layer:", collision_layer)
	print("Player collision mask:", collision_mask)

func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input_vector.length() > 0:

		input_vector = input_vector.normalized() * speed
		velocity = input_vector

		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				current_dir = "right"
			else:
				current_dir = "left"
		else:
			if velocity.y > 0:
				current_dir = "down"
			else:
				current_dir = "up"
			
		play_anim(1)
	else:
		velocity = Vector2.ZERO
		play_anim(0)
		
	move_and_slide()

func play_anim(movement):
	var anim = $AnimatedSprite2D
	
	if current_dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side-walk")
		elif movement == 0:
			anim.play("side-idle")
	elif current_dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side-walk")
		elif movement == 0:
			anim.play("side-idle")
	elif current_dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front-walk")
		elif movement == 0:
			anim.play("front-idle")
	elif current_dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back-walk")
		elif movement == 0:
			anim.play("back-idle")
