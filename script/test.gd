extends Node2D

func _on_portal_body_entered(body):
	if body is friend:
		print(body)
		
	

#func _process(delta: float):
	#change_scenes()

#func change_scenes():
	#if global.transition_scene:
		#if global.current_scene == "home":
			#get_tree().change_scene_to_file("res://scenes/way1.tscn")
		#elif global.current_scene == "way1":
			#get_tree().change_scene_to_file("res://scenes/home.tscn")
		#global.finish_changescenes()
#
#
#func _on_portal_body_exited(body: Node2D) -> void:
	#pass # Replace with function body.
