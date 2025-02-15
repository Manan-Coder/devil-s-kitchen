extends CharacterBody2D
class_name player
const speed = 100
var current_dir: String = "none"
@onready var walk_gravel = $AudioStreamPlayer2D

func _ready():
	$AnimatedSprite2D.play("front-idle")
	print("Player ready!")

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
	
	if movement == 1:
		if not walk_gravel.playing:  
			walk_gravel.play()
	else:
		walk_gravel.stop() 
	
	if current_dir == "right":
		anim.flip_h = false
		anim.play("side-walk" if movement == 1 else "side-idle")
	elif current_dir == "left":
		anim.flip_h = true
		anim.play("side-walk" if movement == 1 else "side-idle")
	elif current_dir == "down":
		anim.flip_h = false
		anim.play("front-walk" if movement == 1 else "front-idle")
	elif current_dir == "up":
		anim.flip_h = true
		anim.play("back-walk" if movement == 1 else "back-idle")
