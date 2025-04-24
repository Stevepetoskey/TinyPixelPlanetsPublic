extends Control

@onready var character: Control = $"../character"
@onready var mode_btn: Button = $VBoxContainer/Mode/ModeBtn
@onready var difficulty_btn: Button = $VBoxContainer/Difficulty/DifficultyBtn
@onready var difficulty_desc: Label = $VBoxContainer/Difficulty/DifficultyDesc
@onready var tutorials_btn: CheckButton = $VBoxContainer/TutorialsBtn

var difficulties : Dictionary = {
	"easy":{"title":"Easy","desc":"Lose nothing on death"},
	"normal":{"title":"Normal","desc":"Lose blues on death"},
	"hard":{"title":"Hard","desc":"Lose everything on death"}
	}

func open() -> void:
	#Default gamerules are set after creating a save, so this will know the gamerules have not been set yet if they don't exist
	if Global.gamerules.has("difficulty"):
		difficulty_btn.text = difficulties[Global.gamerules["difficulty"]]["title"]
		difficulty_desc.text = difficulties[Global.gamerules["difficulty"]]["desc"]
	else:
		difficulty_btn.text = difficulties["normal"]["title"]
		difficulty_desc.text = difficulties["normal"]["desc"]
	if Global.gamerules.has("start_with_godmode"):
		mode_btn.text = "Godmode" if Global.gamerules["start_with_godmode"] else "Survival"
	else:
		mode_btn.text = "Survival"
	if Global.gamerules.has("tutorial"):
		tutorials_btn.button_pressed = Global.gamerules["tutorial"]
	else:
		tutorials_btn.button_pressed = Global.settings["tutorial_autoset_to"]
	show()

func _on_mode_btn_pressed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	if Global.gamerules.has("start_with_godmode"):
		Global.gamerules["start_with_godmode"] = !Global.gamerules["start_with_godmode"]
	else:
		Global.gamerules["start_with_godmode"] = true
	mode_btn.text = "Godmode" if Global.gamerules["start_with_godmode"] else "Survival"

func _on_difficulty_btn_pressed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	if Global.gamerules.has("difficulty"):
		var currentDifficulty = Global.gamerules["difficulty"]
		Global.gamerules["difficulty"] = "easy" if difficulties.keys().find(currentDifficulty) + 1 >= difficulties.size() else difficulties.keys()[difficulties.keys().find(currentDifficulty) + 1]
	else:
		Global.gamerules["difficulty"] = "hard"
	difficulty_btn.text = difficulties[Global.gamerules["difficulty"]]["title"]
	difficulty_desc.text = difficulties[Global.gamerules["difficulty"]]["desc"]


func _on_game_settings_btn_pressed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	character.show()
	hide()

func _on_tutorials_btn_toggled(toggled_on: bool) -> void:
	print("button toggled")
	GlobalAudio.play_ui_sound("button_pressed")
	Global.gamerules["tutorial"] = toggled_on
	Global.settings["tutorial_autoset_to"] = toggled_on
	print(Global.gamerules["tutorial"])
	Global.save_settings()
