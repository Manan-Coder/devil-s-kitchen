extends Area2D

func _ready():
	print("Script runs!")
	# Connect signals via code instead of editor
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Something entered!")
	print(body.name)

func _on_body_exited(body):
	print("Something left!")
