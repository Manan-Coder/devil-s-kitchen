extends Area2D

func _ready():
	print("Area2D is ready!")
	monitoring = true
	monitorable = true
	print("Monitoring state:", monitoring)
	

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Body entered: ", body.name)
	if body is player:
		print("Player detected!")
		GlobalSignals.emit_signal("player_near_friend") 
		#get_tree().change_scene_to_file("res://scenes/way1.tscn")
		
func _on_body_exited(body):
	print("Body exited: ", body.name)
