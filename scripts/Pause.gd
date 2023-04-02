extends Control

onready var inventory = get_node("../Inventory")
onready var cursor = get_node("../../Cursor")
onready var world = get_node("../../World")

func _process(_delta):
	if !inventory.visible and Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause(toggle = true, setValue = false):
	if toggle:
		setValue = !visible
	visible = setValue
	cursor.pause = setValue
	inventory.invPause = setValue

func _on_Quit_pressed():
	Global.save(world.get_world_data())
	yield(get_tree(),"idle_frame")
	get_node("../Black/AnimationPlayer").play("fadeIn")
	yield(get_node("../Black/AnimationPlayer"),"animation_finished")
	var _er = get_tree().change_scene("res://scenes/Menu.tscn")

func _on_Save_pressed():
	Global.save(world.get_world_data())

func _on_Continue_pressed():
	toggle_pause(false)
