extends AnimationPlayer

var interactions = 0


func _ready():
	var err = GlobalSignals.connect("player_near_friend", _on_player_entered)
	if err != OK:
		print("Error connecting signal: ", err)


func _on_player_entered():
	if interactions == 0:
		print("trigerring talking cutscene")
		play("1st")
		interactions = 1

		
	else:
		pass
