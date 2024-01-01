extends Control

export var type = "planet"

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		match type:
			"planet":
				if !get_node("../Dead").visible and !get_node("../Inventory").visible:
					toggle_pause()
			_:
				toggle_pause()

func toggle_pause(toggle = true, setValue = false):
	if toggle:
		setValue = !visible
	visible = setValue
	Global.pause = setValue

func _on_Quit_pressed():
	match type:
		"planet":
			Global.save(type,$"../../World".get_world_data())
		"system":
			Global.save(type,$"../..".get_save_data())
		"galaxy":
			Global.save(type,{})
	yield(get_tree(),"idle_frame")
	$Black/AnimationPlayer.play("fadeIn")
	yield($Black/AnimationPlayer,"animation_finished")
	var _er = get_tree().change_scene("res://scenes/Menu.tscn")

func _on_Save_pressed():
	match type:
		"planet":
			Global.save(type,$"../../World".get_world_data())
		"system":
			Global.save(type,$"../..".get_save_data())
		"galaxy":
			Global.save(type,{})

func _on_Continue_pressed():
	toggle_pause(false)
