extends Area2D

func _ready():
	print("Area2D is ready!")
	monitoring = true
	monitorable = true
	print("Monitoring state:", monitoring)
	

	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Body entered: ", body.name)
	print("Player detected!")
		
func _on_body_exited(body):
	print("Body exited: ", body.name)
