extends Node

var musicPool = {
	"regular":[preload("res://Audio/music/TinyPlanets.ogg"),preload("res://Audio/music/Alpha-Andromedae.ogg"),preload("res://Audio/music/Cosmic-Wonders.wav"),preload("res://Audio/music/The-Edge-of-Time.wav"),preload("res://Audio/music/Tiny-Systems.wav")],
	"space":[preload("res://Audio/music/Found.wav"),preload("res://Audio/music/Lost_in_space.wav")]
	}

var mode = "menu"
var currentMusic = "regular"

var musicRng = RandomNumberGenerator.new()

func _ready():
	musicRng.seed = randi()
	StarSystem.connect("leaving_system",self,"leaving_system")
	StarSystem.connect("entering_system",self,"entering_system")
	Global.connect("saved_settings",self,"update_volume")

func update_volume():
	print("volume change", Global.settings["music"])
	$Music.volume_db = (Global.settings["music"]*5) - 50
	if Global.settings["music"] == 0:
		$Music.volume_db = -100

func update_music():
	match mode:
		"game":
			$Music.stream = musicPool[currentMusic][musicRng.randi()%musicPool[currentMusic].size()]
			$Music.play()
			$Music/MusicTimer.start(musicRng.randf_range(220,420))
		"menu":
			$Music.stop()

func change_mode(type : String):
	if mode != type:
		mode = type
		update_music()

func leaving_system():
	$Music/AnimationPlayer.play("vol_down")
	yield($Music/AnimationPlayer,"animation_finished")
	currentMusic = "space"
	update_music()
	$Music/AnimationPlayer.play("vol_up")

func entering_system():
	$Music/AnimationPlayer.play("vol_down")
	yield($Music/AnimationPlayer,"animation_finished")
	currentMusic = "regular"
	update_music()
	$Music/AnimationPlayer.play("vol_up")

func _on_MusicTimer_timeout():
	update_music()
