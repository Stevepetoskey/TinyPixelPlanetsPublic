extends Node2D

var music = [preload("res://Audio/music/TinyPlanets.ogg"),preload("res://Audio/music/Alpha-Andromedae.ogg"),preload("res://Audio/music/Cosmic-Wonders.wav"),preload("res://Audio/music/The-Edge-of-Time.wav")]

func _ready():
	$CanvasLayer/Black.show()

func _process(delta):
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())

func play_bg_music():
	$Music.stream = music[randi()%4]
	$Music.play()
	$Music/Timer.start(rand_range(240,720))

func _on_Timer_timeout():
	if !$Music.playing:
		play_bg_music()

func _on_World_world_loaded():
	$Music/Timer.start(rand_range(20,120))
