extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("player here!")
	if global.boars_killed == 5:
		print("scene changing")
		get_tree().change_scene_to_file("res://scenes/techy.tscn")
	else:
		print("no cheating")
