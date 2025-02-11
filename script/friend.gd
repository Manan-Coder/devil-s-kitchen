extends CharacterBody2D

const speed = 100
var current_dir = "none"
@onready var camera = $Camera2D
func _ready():
	$AnimatedSprite2D.play("front-idle")
	var scene_name = get_tree().current_scene.name  # Get current scene name
	var limits = SceneManager.get_camera_limits(scene_name)

	if limits:
		camera.limit_left = limits["left"]
		camera.limit_right = limits["right"]
		camera.limit_top = limits["top"]
		camera.limit_bottom = limits["bottom"]
func _physics_process(delta):
	player_movement(delta)

func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		velocity.y = 0
		current_dir = "right"
		play_anim(1)
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		velocity.y = 0
		current_dir = "left"
		play_anim(1)
	elif Input.is_action_pressed("ui_down"):
		velocity.x = 0
		velocity.y = speed
		current_dir = "down"
		play_anim(1)
	elif Input.is_action_pressed("ui_up"):
		velocity.x = 0
		velocity.y = -speed
		current_dir = "up"
		play_anim(1)
	else:
		velocity.x = 0
		velocity.y = 0
		play_anim(0)
		
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side-walk")
		elif movement == 0:
			anim.play("side-idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side-walk")
		elif movement == 0:
			anim.play("side-idle")
		
	if dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front-walk")
		elif movement == 0:
			anim.play("front-idle")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("back-walk")
		elif movement == 0:
			anim.play("back-idle")
