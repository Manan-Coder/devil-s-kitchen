extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cutscene_fall_body_entered(body: Node2D) -> void:
	if global.friend_fallen == 0:
		print("playing fall")
		play("main")
		global.friend_fallen = 1
	else:
		pass
