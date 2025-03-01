extends CharacterBody2D

func _ready() -> void:
	$AnimatedSprite2D.play("main")


func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.visible = false
	global.gun_got = true
