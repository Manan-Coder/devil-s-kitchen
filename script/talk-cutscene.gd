extends AnimationPlayer

var interactions = 0


func _ready():
	var err = GlobalSignals.connect("player_near_friend", _on_player_entered)
	if err != OK:
		print("Error connecting signal: ", err)


func _on_player_entered():
	if global.friend_interaction_cutscene == 0:
		print("trigerring talking cutscene")
		play("1st")
		global.friend_interaction_cutscene = 1		
	else:
		pass
