extends Node

var musicPool = {
	"regular":[preload("res://Audio/music/TinyPlanets.ogg"),preload("res://Audio/music/Cosmic-Wonders.ogg"),preload("res://Audio/music/The-Edge-of-Time.ogg"),preload("res://Audio/music/Tiny-Systems.ogg"),preload("res://Audio/music/Universe-Gears.ogg")],
	"space":[preload("res://Audio/music/Found.ogg"),preload("res://Audio/music/Lost_in_space.ogg")],
	"chip":{238:preload("res://Audio/music/Alpha-Andromedae.ogg"),239:preload("res://Audio/music/Past.ogg"),240:preload("res://Audio/music/Tinkering-Machine.ogg")}
	}

var uiPool : Dictionary = {
	"button_pressed":preload("res://Audio/sfx/GUI/bong_001.ogg")
}

var soundData : Dictionary = {
	"grass":{
		"step":"step/grass",
		"place":"place/grass",
		"break":"place/grass"
	},
	"snow":{
		"step":"step/snow",
		"place":"place/grass",
		"break":"place/grass"
	},
	"stone":{
		"step":"step/stone",
		"place":"place/stone",
		"break":"place/stone"
	},
	"wood":{
		"step":"step/wood",
		"place":"place/wood",
		"break":"place/wood"
	},
	"sand":{
		"step":"step/sand",
		"place":"place/sand",
		"break":"place/sand"
	},
	"glass":{
		"step":"step/glass",
		"place":"step/glass",
		"break":"break/glass"
	},
	"metal":{
		"step":"step/metal",
		"place":"place/metal",
		"break":"place/metal"
	},
	"wool":{
		"step":"place/grass",
		"place":"place/grass",
		"break":"place/grass"
	}
}

var mode = "menu"
var currentMusic = "regular"
var inBossFight : bool = false

var musicRng = RandomNumberGenerator.new()

@onready var sound_effects_hold: Node = $SoundEffectsHold

func _ready():
	musicRng.seed = randi()
	StarSystem.leaving_system.connect(leaving_system)
	StarSystem.entering_system.connect(entering_system)
	Global.audio_changed.connect(update_audio)
	update_audio()

func get_volume(category : String) -> int:
	if Global.settings[category] <= 0:
		return -100
	return (Global.settings[category]*5) - 50

func update_audio() -> void:
	$Music.volume_db = get_volume("music")
	$BossMusic.volume_db = get_volume("music")
	$UI.volume_db = get_volume("sfx")

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

func play_ui_sound(sfx : String) -> void:
	if uiPool.has(sfx):
		$UI.stream = uiPool[sfx]
		$UI.play()

func play_sound_effect(sfx : String) -> void:
	var newSFX : AudioStreamPlayer = AudioStreamPlayer.new()
	newSFX.stream = load("res://Audio/sfx/" + sfx)
	newSFX.volume_db = get_volume("sfx")
	sound_effects_hold.add_child(newSFX)
	newSFX.play()

func play_sound_effect_2d(sfx : String, pos : Vector2) -> void:
	var newSFX : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	newSFX.stream = load("res://Audio/sfx/" + sfx)
	newSFX.position = pos
	newSFX.volume_db = get_volume("sfx")
	sound_effects_hold.add_child(newSFX)
	newSFX.play()

func get_block_audios(file : String) -> Array:
	var files : Array = []
	var i : int = 0
	while ResourceLoader.exists("res://Audio/sfx/blocks/" + file + "/"+ str(i)+".ogg"):
		files.append("blocks/"+file + "/" + str(i) + ".ogg")
		i += 1
	return files

func play_block_audio(id : int,action : String) -> void:
	if soundData.has(GlobalData.get_item_data(id)["sound_file"]):
		var soundFiles : Array = get_block_audios(soundData[GlobalData.get_item_data(id)["sound_file"]][action])
		play_sound_effect(soundFiles.pick_random())

func play_block_audio_2d(id : int,action : String,pos : Vector2) -> void:
	if soundData.has(GlobalData.get_item_data(id)["sound_file"]):
		var soundFiles : Array = get_block_audios(soundData[GlobalData.get_item_data(id)["sound_file"]][action])
		play_sound_effect_2d(soundFiles.pick_random(),pos)

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
	var tween = create_tween().tween_property($Music,"volume_db",-75,1)
	await tween.finished
	currentMusic = "space"
	update_music()
	var tween2 = create_tween().tween_property($Music,"volume_db",get_volume("music"),1)

func entering_system():
	var tween = create_tween().tween_property($Music,"volume_db",-75,1)
	await tween.finished
	currentMusic = "regular"
	update_music()
	var tween2 = create_tween().tween_property($Music,"volume_db",get_volume("music"),1)

func _on_MusicTimer_timeout():
	update_music()
