extends AudioStreamPlayer2D

var tracks = [
	preload("res://art/music/soundtracks/Cuddle Clouds.wav"),
	preload("res://art/music/soundtracks/Floating Dream.wav"),
	preload("res://art/music/soundtracks/Gentle Breeze.wav"),
	preload("res://art/music/soundtracks/Golden Gleam.wav")
]

func _ready():
	randomize()
	connect("finished", Callable(self, "_on_finished"))
	play_random()

func play_random():
	var random_i = randi() % tracks.size()
	stream = tracks[random_i]
	play()

func _on_finished():
	play_random()
