extends CharacterBody2D
var health = 4
var max_health = 4
var speed = 250.0
var player_reference = null
const ATTACK_RANGE = 30.0 
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

func _ready() -> void:
	animated_sprite.play("idle")
	setup_health_bar()

func setup_health_bar() -> void:
	
	if !has_node("HealthBar"):
		var container = HBoxContainer.new()
		container.name = "HealthBar"
		container.position = Vector2(0, -20)  
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		container.custom_minimum_size = Vector2(40, 8)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		
		container.position.x = -20  
		
		add_child(container)
		health_bar = container
	
	update_health_bar()

func update_health_bar() -> void:
	
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
		bar.custom_minimum_size = Vector2(2, 3)
		bar.color = color
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		
		var margin = MarginContainer.new()
		margin.custom_minimum_size = Vector2(2, 2)
		margin.add_child(bar)
		
		health_bar.add_child(margin)

func _physics_process(delta: float) -> void:
	if player_reference and is_instance_valid(player_reference):
		chase_player(delta)
	else:
		velocity.x = 0
		animated_sprite.play("idle")
	

	if player_reference and is_instance_valid(player_reference):
		animated_sprite.flip_h = (player_reference.global_position.x > global_position.x)
	
	move_and_slide()

func chase_player(delta: float) -> void:
	var direction = player_reference.global_position.x - global_position.x
	var distance = abs(direction)
	
	if distance > ATTACK_RANGE:
		velocity.x = sign(direction) * speed
		animated_sprite.play("walk")
	else:
		velocity.x = 0
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
			attack()

func attack() -> void:
	if player_reference and player_reference.has_method("take_damage"):
		player_reference.take_damage(1)

func take_damage(amount: int) -> void:
	health -= amount
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
	
	
	if health_bar:
		health_bar.visible = false
		
	animated_sprite.play("attack")
	await get_tree().create_timer(1.0).timeout
	visible = false
	global.boars_killed+=1
	print(global.boars_killed)
	queue_free()

func _on_detection_body_entered(body) -> void:
	if body != self:
		player_reference = body
		print("Player entered detection area")

func _on_detection_body_exited(body) -> void:
	if body == player_reference:
		player_reference = null
		print("Player left detection area")


func hit_by_bullet() -> void:
	take_damage(1)


func _on_bullet_detection_body_entered(body: Node2D) -> void:
	print("bullet!!!!!!!!")
	hit_by_bullet()
