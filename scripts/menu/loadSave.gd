extends Control

var selectedSave = ""

func update_save_list() -> void:
	for save in $saves.get_children():
		var dir = Directory.new()
		if dir.dir_exists(Global.save_path + save.name):
			save.get_node("stats").hide()
			save.get_node("delete").show()
		else:
			save.get_node("stats").show()
			save.get_node("delete").hide()

func save_clicked(save : Object) -> void:
	selectedSave = save.name
	if Global.save_exists(save.name):
		start()
	else:
		hide()
		get_node("../character").open()

func delete_file(save : Object) -> void:
	Global.delete(save.name)
	update_save_list()

func cancel():
	selectedSave = ""
	show()

func start(tutorial = false):
	get_node("..").hide()
	get_node("../../blank").show()
	get_node("../../AnimationPlayer").play("zoom",-1,-1,true)
	yield(get_node("../../AnimationPlayer"),"animation_finished")
	if tutorial:
		Global.open_tutorial()
	else:
		Global.open_save(selectedSave)
