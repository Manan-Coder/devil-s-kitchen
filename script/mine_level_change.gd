extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if global.boar_killed_out >= 3:
		print(global.boar_killed_out," boars killed")
		global.level_boar = 1
		global.make_spidey = true
		global.gun_got = false
		get_tree().change_scene_to_file("res://scenes/next_mine.tscn")
	print("got player")
