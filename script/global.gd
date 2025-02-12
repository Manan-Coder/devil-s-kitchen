extends Node

var current_scene = "home"
var transition_scene = false

var player_exit_home_x = 0
var player_exit_home_y = 0
var player_start_home_x = 0
var player_start_home_y = 0

func finish_changescenes():
	transition_scene = false  # reset flag
	# Toggle current_scene for demonstration; adjust as needed.
	if current_scene == "home":
		current_scene = "way1"
	else:
		current_scene = "home"
