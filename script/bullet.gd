extends CharacterBody2D

signal hit_something(body)

@export var speed = 2000
@export var max_distance = 750  
@export var bullet_lifetime = 1.5  

var pos: Vector2 
var dir: float   
var distance_traveled = 0
var starting_pos: Vector2


func _on_area_2d_body_entered(body: Node2D) -> void:
	emit_signal("hit_something", body)
	queue_free()  

func _ready() -> void:
	global_position = pos
	global_rotation = dir
	starting_pos = global_position
	

	var timer = get_tree().create_timer(bullet_lifetime)
	timer.timeout.connect(func(): queue_free())

func _physics_process(delta: float) -> void:
	
	velocity = Vector2(speed, 0).rotated(dir)
	

	var prev_pos = global_position
	
	
	var collision = move_and_collide(velocity * delta)
	
	
	distance_traveled += global_position.distance_to(prev_pos)
	
	
	if collision:
		emit_signal("hit_something", collision.get_collider())
		queue_free()
	
	
	if distance_traveled >= max_distance:
		queue_free()
