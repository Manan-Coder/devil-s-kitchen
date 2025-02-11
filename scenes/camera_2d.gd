extends Camera2D

func _ready():
	update_camera_limits()

func update_camera_limits():
	var current_scene = get_tree().current_scene  # Get active scene
	
	if current_scene:
		var world_rect = current_scene.get_viewport_rect().size  # Get scene size
		
		limit_left = 0
		limit_top = 0
		limit_right = world_rect.x
		limit_bottom = world_rect.y

		print("Updated Camera Limits: ", limit_left, limit_right, limit_top, limit_bottom)
