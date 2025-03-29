extends CharacterBody2D
class_name player

const speed = 100
var current_dir: String = "none"
@onready var walk_gravel = $AudioStreamPlayer2D
@onready var cam = $Camera2D

var input_blocked = false 
var interactions = 0


func _ready():
	$AnimatedSprite2D.play("front-idle")
	print("Player ready!")
	var err = GlobalSignals.connect("player_near_friend", _on_player_entered)
	if err != OK:
		print("Error connecting signal: ", err)

func _physics_process(delta):
	if input_blocked:
		velocity = Vector2.ZERO
		move_and_slide()
		$AnimatedSprite2D.play("back-idle")	
		return  
	
	player_movement(delta)

	
	move_and_slide()

func player_movement(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_vector.length() > 0:
		input_vector = input_vector.normalized() * speed
		velocity = input_vector
		
		if abs(velocity.x) > abs(velocity.y):
			current_dir = "right" if velocity.x > 0 else "left"
		else:
			current_dir = "down" if velocity.y > 0 else "up"

		play_anim(1)
	else:
		velocity = Vector2.ZERO
		play_anim(0)



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

func _on_player_entered():
	if global.friend_interaction_player_pause == 0:
		print("Blocking player movement for 55 seconds")
		input_blocked = true  

		await get_tree().create_timer(55.0).timeout 

		input_blocked = false
		global.friend_interaction_player_pause = 1
		print("Inputs back!")


func _on_area_2d_body_entered(body: Node2D):
	print("car found!")
	velocity = Vector2.ZERO
	move_and_slide()
	visible = false
	cam.enabled = false
	GlobalSignals.emit_signal("player_entered_car")
	return


func _on_vent_1_body_entered(body: Node2D) -> void:
	if global.key_got:
		global.vents_crossed+=1
		if global.vents_crossed==1:
			await get_tree().create_timer(2).timeout
			visible = false
			position = Vector2(405,166)
			visible = true
			global.key_got = false


func _on_vent_2_body_entered(body: Node2D) -> void:
	global.vent2+=1
	if global.vent2 == 1:
		await get_tree().create_timer(2).timeout
		$Camera2D.enabled = false
		velocity = Vector2.ZERO
	
	


func _on_lvl_1_end_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	$Camera2D.enabled = true
	position = Vector2(755,190)
	


func _on_lvlchange_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	$Camera2D.enabled = false


func _on_lvl_back_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	$Camera2D.enabled = true
	position = Vector2(1046,86)


func _on_poschange_body_entered(body: Node2D) -> void:
	global.vent3+=1
	if global.vent3 == 1:
		await get_tree().create_timer(2).timeout
		position = Vector2(667,195)
		await get_tree().create_timer(2).timeout
		position = Vector2(667,93)


func _on_machine_body_entered(body: Node2D) -> void:
	if global.shard_got:
		global.shard_in = true
		print("shard in machine")


func _on_vent_body_entered(body: Node2D) -> void:
	if global.shard_in:
		print("ready to change")
		await get_tree().create_timer(2).timeout
		position = Vector2(406,159)


func _on_ventdark_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	print("changing!!")
	position = Vector2(757,193)


func _on_levelchangetodark_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	await get_tree().change_scene_to_file("res://scenes/techy_2.tscn")


func _on_lightmachine_body_entered(body: Node2D) -> void:
	if global.light_shard_got:
		$PointLight2D.visible = false
