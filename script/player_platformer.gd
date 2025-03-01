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
# Health system variables
var health = 5
var max_health = 5
var is_taking_boar_damage = false
var damage_timer = 0.0
var damage_interval = 1.0  # Take damage every 1 second
var has_interacted_with_boar = false
@onready var health_bar = null

# Bullet system variables
var can_shoot = true
var bullet_cooldown = 0.5  # Time between shots
var bullet_speed = 600.0   # Speed of bullets
var bullet_damage = 1      # Damage each bullet deals

var is_jumping = false
var jump_timer = 0.0

func _ready() -> void:
	$AnimatedSprite2D.play("side-idle")
	
	# Don't set up health bar at start - wait for boar interaction

func setup_health_bar() -> void:
	# Create health bar container if it doesn't exist
	if !has_node("HealthBar"):
		var container = HBoxContainer.new()
		container.name = "HealthBar"
		container.position = Vector2(0, -30)  # Position above player
		container.custom_minimum_size = Vector2(50, 10)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Center the health bar
		container.position.x = -25  # Half of the width
		
		add_child(container)
		health_bar = container
	
	update_health_bar()

func update_health_bar() -> void:
	if !health_bar:
		return
		
	# Clear existing health indicators
	for child in health_bar.get_children():
		child.queue_free()
	
	# Determine color based on health percentage
	var color = Color.GREEN
	var health_percentage = float(health) / max_health
	
	if health_percentage <= 0.25:
		color = Color.RED
	elif health_percentage <= 0.5:
		color = Color.YELLOW
	
	# Add health indicators (bars)
	for i in range(health):
		var bar = ColorRect.new()
		bar.custom_minimum_size = Vector2(8, 8)
		bar.color = color
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Add a small margin between bars
		var margin = MarginContainer.new()
		margin.custom_minimum_size = Vector2(10, 8)
		margin.add_child(bar)
		
		health_bar.add_child(margin)

func _physics_process(delta: float) -> void:
	var potion_active = global.potion_active 
	if Input.is_action_just_pressed("ui_accept") && global.gun_got == true:
		fire()
	# Handle boar damage timer
	if is_taking_boar_damage:
		damage_timer += delta
		if damage_timer >= damage_interval:
			take_damage(1)
			damage_timer = 0.0  # Reset timer
	
	# Handle shooting
	if Input.is_action_just_pressed("ui_select") and can_shoot:  # Space bar
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
		
		# Determine the direction the player is facing
		var direction = Vector2.RIGHT if not $AnimatedSprite2D.flip_h else Vector2.LEFT
		
		# Adjust bullet spawn position
		var spawn_offset = direction * 20  # 20 pixels in front of the player
		bullet.position = position + spawn_offset
		
		# Set bullet velocity
		bullet.velocity = direction * bullet_speed
		
		# Rotate the bullet to match direction
		bullet.rotation = direction.angle()
		
		# Add bullet to the scene
		get_parent().add_child(bullet)


func create_bullet() -> CharacterBody2D:
	# Create a new CharacterBody2D for the bullet
	var bullet = CharacterBody2D.new()
	bullet.name = "PlayerBullet"
	
	# Set up collision
	var collision = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.radius = 3
	shape.height = 10
	collision.shape = shape
	collision.rotation_degrees = 90  # Rotate to make capsule horizontal
	bullet.add_child(collision)
	
	# Create visual for the bullet
	var sprite = ColorRect.new()
	sprite.color = Color.WHITE
	sprite.custom_minimum_size = Vector2(10, 6)
	sprite.position = Vector2(-5, -3)  # Center the rectangle
	bullet.add_child(sprite)
	
	# Make the bullet deletable
	bullet.set_meta("damage", bullet_damage)
	
	# Add script to the bullet
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
		# Flash red when taking damage
		modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 1, 1)

func die() -> void:
	# Handle player death
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# Play death animation if you have one
	# $AnimatedSprite2D.play("death")
	
	# For now, just change color to indicate death
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	# You might want to add game over logic here
	print("Player died!")
	
	# Could restart level or show game over screen
	await get_tree().create_timer(2.0).timeout
	await get_tree().change_scene_to_file("res://scenes/mine_outside.tscn")

func _on_boar_detection_body_entered(body: Node2D) -> void:
	print("boar-detected")
	is_taking_boar_damage = true
	damage_timer = 0.0  # Reset timer to start fresh
	
	# Create health bar on first boar interaction
	if !has_interacted_with_boar:
		has_interacted_with_boar = true
		setup_health_bar()

func _on_boar_detection_body_exited(body: Node2D) -> void:
	print("boar out")
	is_taking_boar_damage = false
	damage_timer = 0.0  # Reset timer
	
func fire():
	var bullet = bullet_path.instantiate()
	
	# Set bullet position
	bullet.pos = global_position
	
	# Set direction based on player's facing direction
	if $AnimatedSprite2D.flip_h == true:
		# Player is facing left
		bullet.dir = PI  # PI = left (180 degrees)
	else:
		# Player is facing right
		bullet.dir = 0   # 0 = right (0 degrees)
	
	# Add the bullet to the scene
	get_parent().add_child(bullet)
