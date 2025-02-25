extends Area2D

func _ready():
	print("Area2D is ready! sigma")
	monitoring = true
	monitorable = true
	print("Monitoring state: sigma : ", monitoring)
	

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Body entered: ", body.name)

	print("car detected! sigma")
	get_tree().change_scene_to_file("res://scenes/garage-out.tscn")
		
func _on_body_exited(body):
	print("Body exited: ", body.name)
