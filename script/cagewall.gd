extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_freefriend_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(3).timeout
	$CollisionPolygon2D.disabled = true
	self.set_deferred("collision_layer",0)
