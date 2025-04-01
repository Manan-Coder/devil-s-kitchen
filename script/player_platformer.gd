extends CharacterBody2D
class_name player_p
const SPEED = 300.0
const GRAVITY = 980.0
var normal_gravity = GRAVITY
var current_gravity = GRAVITY
var anti_gravity = -200
var is_anti_gravity = false
var jump_force = -500
var is_in_anti_grav = false
var rotation_speed = 3.0
const NORMAL_JUMP_VELOCITY = -900.0
const MIN_JUMP_VELOCITY = -1200.0
const JUMP_HOLD_GRAVITY = 125.0
const JUMP_HOLD_TIME = 0.8
const POTION_JUMP_VELOCITY = -900.0  
const POTION_JUMP_HOLD_GRAVITY = 250.0  
var anti_num = 0
var bullet_path = preload("res://scenes/bullet.tscn")

var health = 5
var max_health = 5
var is_taking_boar_damage = false
var damage_timer = 0.0
var damage_interval = 1.0 
var has_interacted_with_boar = false
@onready var health_bar = null


var can_shoot = true
var bullet_cooldown = 0.5 
var bullet_speed = 600.0   
var bullet_damage = 1     
var grav = 300
var custom_gravity = grav
var is_jumping = false
var jump_timer = 0.0
@onready var cam = $Camera2D
func _ready() -> void:
	$AnimatedSprite2D.play("side-idle")
	


func setup_health_bar() -> void:

	if !has_node("HealthBar"):
		var container = HBoxContainer.new()
		container.name = "HealthBar"
		container.position = Vector2(0, -30) 
		container.custom_minimum_size = Vector2(50, 10)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	
		container.position.x = -25
		
		add_child(container)
		health_bar = container
	
	update_health_bar()

func update_health_bar() -> void:
	if !health_bar:
		return

	for child in health_bar.get_children():
		child.queue_free()
	

	var color = Color.GREEN
	var health_percentage = float(health) / max_health
	
	if health_percentage <= 0.25:
		color = Color.RED
	elif health_percentage <= 0.5:
		color = Color.YELLOW
	

	for i in range(health):
		var bar = ColorRect.new()
		bar.custom_minimum_size = Vector2(8, 8)
		bar.color = color
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var margin = MarginContainer.new()
		margin.custom_minimum_size = Vector2(10, 8)
		margin.add_child(bar)
		
		health_bar.add_child(margin)
func _physics_process(delta: float) -> void:

	var potion_active = global.potion_active 
	if global.level_grav == 1 and is_anti_gravity:
		velocity.y += anti_gravity * delta
	else:
		velocity.y += GRAVITY * delta

	
	if Input.is_action_just_pressed("ui_accept") and global.gun_got and can_shoot:
		can_shoot = false
		fire()
		await get_tree().create_timer(1).timeout  
		can_shoot = true
	
	if is_in_anti_grav:
		rotation += rotation_speed * delta
	else:
		rotation = move_toward(rotation, 0, rotation_speed * delta)
	
	if Input.is_action_just_pressed("ui_select") and can_shoot:
		can_shoot = false
		shoot()
		await get_tree().create_timer(bullet_cooldown).timeout
		can_shoot = true
	

	if is_taking_boar_damage:
		damage_timer += delta
		if damage_timer >= damage_interval:
			take_damage(1)
			damage_timer = 0.0
	

	if not is_on_floor():
		if is_jumping and Input.is_action_pressed("ui_up") and jump_timer < JUMP_HOLD_TIME:
			velocity.y += (POTION_JUMP_HOLD_GRAVITY if potion_active else JUMP_HOLD_GRAVITY) * delta
			jump_timer += delta
		else:
			velocity.y += current_gravity * delta
	else:
		is_jumping = false
		jump_timer = 0.0  
		
	if Input.is_action_pressed("ui_up") and is_on_floor():
		if not potion_active:
			velocity.y = POTION_JUMP_VELOCITY
		else:
			velocity.y = MIN_JUMP_VELOCITY*1.2
		is_jumping = true
		jump_timer = 0.0  
		if abs(velocity.x) < 100:
			velocity.x += (200 if $AnimatedSprite2D.flip_h == false else -200)
		

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("side-walk")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("side-idle")
	if is_anti_gravity and global.level_grav == 1:

		if Input.is_action_pressed("ui_up"):
			velocity.y -= 20 
		elif Input.is_action_pressed("ui_down"):
			velocity.y += 20  


	move_and_slide()


func shoot() -> void:
	if global.make_spidey == true:
		var bullet = create_bullet()
		

		var direction = Vector2.RIGHT if not $AnimatedSprite2D.flip_h else Vector2.LEFT
		

		var spawn_offset = direction * 20  
		bullet.position = position + spawn_offset
	
		bullet.velocity = direction * bullet_speed
		

		bullet.rotation = direction.angle()
	
		get_parent().add_child(bullet)


func create_bullet() -> CharacterBody2D:

	var bullet = CharacterBody2D.new()
	bullet.name = "PlayerBullet"
	

	var collision = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.radius = 3
	shape.height = 12
	collision.shape = shape
	collision.rotation_degrees = 90  
	bullet.add_child(collision)
	

	var sprite = ColorRect.new()
	sprite.color = Color.DARK_GREEN
	sprite.custom_minimum_size = Vector2(10, 6)
	sprite.position = Vector2(-5, -3) 
	bullet.add_child(sprite)

	bullet.set_meta("damage", bullet_damage)
	

	var script = GDScript.new()
	script.source_code = """
extends CharacterBody2D

var velocity = Vector2.ZERO
var lifetime = 2.0  # Bullet will be deleted after this time
var damage = 1

func _ready() -> void:
	# Set up timer for automatic deletion
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)
	
	# Get damage value from metadata if set
	if has_meta("damage"):
		damage = get_meta("damage")

func _physics_process(delta: float) -> void:
	# Move the bullet
	var collision = move_and_collide(velocity * delta)
	
	# Check for collision
	if collision:
		var collider = collision.get_collider()
		
		# If we hit something that can take damage
		if collider.has_method("hit_by_bullet"):
			collider.hit_by_bullet(damage)
		
		# Delete bullet on any collision
		queue_free()
"""
	bullet.set_script(script)
	
	return bullet

func take_damage(amount: int) -> void:
	health -= amount
	
	if health_bar:
		update_health_bar()
	
	if health <= 0:
		die()
	else:

		modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 1, 1)

func die() -> void:

	set_physics_process(false)
	velocity = Vector2.ZERO
	

	modulate = Color(0.5, 0.5, 0.5, 0.5)

	print("Player died!")
	
	$AnimatedSprite2D.play("dead")
	await get_tree().create_timer(2.0).timeout
	if global.boar_inter == 0:
		await get_tree().change_scene_to_file("res://scenes/mine_outside.tscn")
	else:
		set_physics_process(true)
		velocity = Vector2.ZERO
		modulate = Color(1,1,1,1)
		position = Vector2(-3300,900)
		health = 5
		

func _on_boar_detection_body_entered(body: Node2D) -> void:
	print("boar-detected")
	is_taking_boar_damage = true
	damage_timer = 0.0  
	

	if !has_interacted_with_boar:
		has_interacted_with_boar = true
		setup_health_bar()

func _on_boar_detection_body_exited(body: Node2D) -> void:
	print("boar out")
	is_taking_boar_damage = false
	damage_timer = 0.0 
	
func fire():
	var bullet = bullet_path.instantiate()
	

	bullet.pos = global_position
	

	if $AnimatedSprite2D.flip_h == true:
	
		bullet.dir = PI 
	else:

		bullet.dir = 0   
	

	get_parent().add_child(bullet)


func _on_change_pos_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("player in")
	position = Vector2(-3300,900)
	cam.limit_left = -10000
	cam.limit_bottom = 3700
	cam.limit_top = 600
	z_index = 3
	global.potion_active = false
	global.make_spidey = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	global.boar_inter = 1
	global.potion_active = true


func _on_restart_area_body_entered(body: Node2D) -> void:
	position = Vector2(0,0)



	


func _on_vent_2_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	$Camera2D.enabled = true
	


func _on_lvl_1_end_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	print("player in")
	$Camera2D.enabled = false


func _on_antigrav_body_entered(body: Node2D) -> void:
	print("in anti grav")
	current_gravity = anti_gravity
	is_anti_gravity = true
	is_in_anti_grav = true


func _on_antigrav_body_exited(body: Node2D) -> void:
	print("out anti grav")
	current_gravity = normal_gravity
	is_anti_gravity = false
	is_in_anti_grav = false 


func _on_lvlchange_body_entered(body: Node2D) -> void:
	$Camera2D.enabled = true


func _on_lvl_back_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(2).timeout
	$Camera2D.enabled = false
	print("camera off of anti")


func _on_poschangearea_body_entered(body: Node2D) -> void:
	position = Vector2(4339,325)
