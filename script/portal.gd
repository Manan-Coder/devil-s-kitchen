extends Area2D
var entered = true
func _on_body_entered(body) -> void:
	if body == player:
		entered = true
func _process(_delta):
	if entered:
		if Input.is_action_just_pressed("ui_select"):
			get_tree().change_scene_to_file("res://scenes/way1.tscn")
