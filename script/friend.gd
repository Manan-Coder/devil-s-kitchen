extends CharacterBody2D 
class_name friends
const speed = 55
var current_dir = "none"
var player_follow = false
var player = null

func _ready():
	$AnimatedSprite2D.play("front-idle")

#func _physics_process(delta: float) -> void:
	#if player_follow:
		#position += (player.position - position) / speed
		#$AnimatedSprite2D.play("front-walk")
		#print("friend approached	")
	#else:
		#$AnimatedSprite2D.play("front-idle")
	



func _on_detection_body_entered(body: Node2D) -> void:
	player = body
	player_follow = true
	


func _on_detection_body_exited(body: Node2D) -> void:
	player = null
	player_follow = false
