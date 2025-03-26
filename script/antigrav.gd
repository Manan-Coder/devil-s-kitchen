extends Area2D

func _ready():
	# Connect the body_entered signal
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	print("Something entered anti-gravity: ", body.name)
	if body is player:  # Ensure you're checking for the player class
		print("Player entered anti-gravity!")
		body._on_antigrav_body_entered(body)

func _on_body_exited(body):
	print("Something exited anti-gravity: ", body.name)
	if body is player:
		print("Player exited anti-gravity!")
		body._on_antigrav_body_exited(body)
