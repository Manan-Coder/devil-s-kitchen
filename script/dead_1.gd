extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if global.friend_fallen == 1:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/mine_outside.tscn")
	else:
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/platformer1.tscn")		
