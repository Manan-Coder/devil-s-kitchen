extends Node

var current_scene = "home"
var transition_scene = false

var player_exit_home_x = 0
var player_exit_home_y = 0
var player_start_home_x = 0
var player_start_home_y = 0

func finish_changescenes():
	transition_scene = false

	if current_scene == "home":
		current_scene = "way1"
	else:
		current_scene = "home"
var friend_interaction_player_pause = 0
var friend_interaction_cutscene = 0
var friend_interaction_friend_pause = 0
var potion_active = false
var gun_got = false
var make_spidey = true
var boars_killed = 0
var friend_fallen = 0
var boar_inter = 0
var boar_killed_out = 0
var level_boar = 0
var key_got = false
var level_grav = 1
var shard_got = false
var shard_in = false
var vents_crossed = 0
var vent2 = 0
var vent3 = 0
var vent4 = 0
var vent5 = 0
var vent6 = 0
var light_shard_got = false
