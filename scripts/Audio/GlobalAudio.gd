extends Node

var musicPool = {
	"regular":[preload("res://Audio/music/TinyPlanets.ogg"),preload("res://Audio/music/Cosmic-Wonders.ogg"),preload("res://Audio/music/The-Edge-of-Time.ogg"),preload("res://Audio/music/Tiny-Systems.ogg"),preload("res://Audio/music/Universe-Gears.ogg")],
	"space":[preload("res://Audio/music/Found.ogg"),preload("res://Audio/music/Lost_in_space.ogg")],
	"chip":{238:preload("res://Audio/music/Alpha-Andromedae.ogg"),239:preload("res://Audio/music/Past.ogg"),240:preload("res://Audio/music/Tinkering-Machine.ogg")}
	}

var mode = "menu"
var currentMusic = "regular"
var inBossFight : bool = false

var musicRng = RandomNumberGenerator.new()

func _ready():
	musicRng.seed = randi()
	StarSystem.connect("leaving_system", Callable(self, "leaving_system"))
	StarSystem.connect("entering_system", Callable(self, "entering_system"))
	Global.connect("saved_settings", Callable(self, "update_volume"))

func update_volume():
	print("volume change", Global.settings["music"])
	$Music.volume_db = (Global.settings["music"]*5) - 50
	if Global.settings["music"] == 0:
		$Music.volume_db = -100

func stop_music():
	$Music.stop()
	$Music/MusicTimer.stop()
	$Music/MusicTimer.start(musicRng.randf_range(220,420))

func update_music():
	match mode:
		"game":
			$Music.stream = musicPool[currentMusic][musicRng.randi()%musicPool[currentMusic].size()]
			$Music.play()
			$Music/MusicTimer.start(musicRng.randf_range(220,420))
		"menu":
			inBossFight = false
			$Music.stop()
			$BossMusic.stop()

func play_boss_music(startFrom : String = "") -> void:
	inBossFight = true
	print("playing boss music")
	$Music.stop()
	$Music/MusicTimer.stop()
	$BossMusic.play()
	if startFrom != "":
		$BossMusic.set("parameters/switch_to_clip",startFrom)
	else:
		$BossMusic.set("parameters/switch_to_clip","")

func stop_boss_music() -> void:
	inBossFight = false
	$BossMusic.stop()
	$Music/MusicTimer.start(musicRng.randf_range(220,420))

func transistion_boss_music(transTo : String) -> void:
	print("Transistioning boss music")
	$BossMusic.set("parameters/switch_to_clip",transTo)

func change_mode(type : String):
	if mode != type:
		mode = type
		update_music()

func leaving_system():
	$Music/AnimationPlayer.play("vol_down")
	await $Music/AnimationPlayer.animation_finished
	currentMusic = "space"
	update_music()
	$Music/AnimationPlayer.play("vol_up")

func entering_system():
	$Music/AnimationPlayer.play("vol_down")
	await $Music/AnimationPlayer.animation_finished
	currentMusic = "regular"
	update_music()
	$Music/AnimationPlayer.play("vol_up")

func _on_MusicTimer_timeout():
	update_music()
