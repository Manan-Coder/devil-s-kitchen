extends Node2D

@export var next_scene : PackedScene
@export var autoplay : bool = false
@export var animation_player : AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cutscene.play("main")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_scene():
	print("changing scenes")
	get_tree().change_scene_to_packed(next_scene)
