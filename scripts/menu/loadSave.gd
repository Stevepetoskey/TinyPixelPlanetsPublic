extends Control


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
	Global.open_save(save.name)
	get_node("..").hide()
	get_node("../../blank").show()
	get_node("../../AnimationPlayer").play("zoom",-1,-1,true)
	yield(get_node("../../AnimationPlayer"),"animation_finished")
	var _er = get_tree().change_scene("res://scenes/Main.tscn")

func delete_file(save : Object) -> void:
	Global.delete(save.name)
	update_save_list()
