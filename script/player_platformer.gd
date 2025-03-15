extends CharacterBody2D
class_name player_p
const SPEED = 300.0
const GRAVITY = 980.0
const NORMAL_JUMP_VELOCITY = -1000.0
const MIN_JUMP_VELOCITY = -550.0
const JUMP_HOLD_GRAVITY = 125.0
const JUMP_HOLD_TIME = 0.3
const POTION_JUMP_VELOCITY = -900.0  
const POTION_JUMP_HOLD_GRAVITY = 250.0  

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
	if Input.is_action_just_pressed("ui_accept") && global.gun_got == true:
		fire()

	if is_taking_boar_damage:
		damage_timer += delta
		if damage_timer >= damage_interval:
			take_damage(1)
			damage_timer = 0.0
	
	if Input.is_action_just_pressed("ui_select") and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(bullet_cooldown).timeout
		can_shoot = true
	
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
	

	await get_tree().create_timer(2.0).timeout
	await get_tree().change_scene_to_file("res://scenes/mine_outside.tscn")

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
	cam.limit_top = 2400
