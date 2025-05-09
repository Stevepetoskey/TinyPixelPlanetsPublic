extends Control

@onready var moon_move: AnimationPlayer = $Path2D/PathFollow2D/MoonMove

func _process(delta: float) -> void:
	$Space.rotation_degrees += delta / 2.0
	$Stars.rotation_degrees += delta / 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.audio_changed.connect(update_audio)
	update_audio()
	$Version.text = Global.CURRENTVER
	$Planet.texture = [load("res://textures/GUI/Menu/planets/terra.png"),load("res://textures/GUI/Menu/planets/mud.png"),load("res://textures/GUI/Menu/planets/desert.png")].pick_random()
	moon_move.play("default")
	GlobalAudio.change_mode("menu")
	#yield(get_tree().create_timer(0.5),"timeout")
	$Main/Title.modulate = Color(1,1,1,0)
	$AnimationPlayer.play("zoom")
	await $AnimationPlayer.animation_finished
	$blank.hide()
	$Main/Title.show()
	$AnimationPlayer.play("title")
	await $AnimationPlayer.animation_finished
	$Main/Buttons.show()
	$AnimationPlayer.play("buttons")

func update_audio() -> void:
	$AudioStreamPlayer.volume_db = GlobalAudio.get_volume("music")

func _on_Play_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	$Main.hide()
	$World/character.hide()
	$World/loadSave.show()
	$World/loadSave.update_save_list()
	$World.show()

func _on_back_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	$Credits.hide()
	$World.hide()
	$Main.show()

func _on_Credits_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	$Main.hide()
	$Credits.show()

func _on_Tutorial_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	OS.shell_open("https://youtube.com/playlist?list=PL5pzkf2g-ciXHFKapja76b7q-Qtil4Ccf&si=K6aRkljHK7sD4QfJ")
	#$World/loadSave.start(true)

func _on_Settings_pressed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	$Main.hide()
	$Settings.display_settings()

func _on_settings_settings_closed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	$Main.show()
