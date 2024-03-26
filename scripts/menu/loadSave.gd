extends Control

var selectedSave = ""

onready var scenarios = $"../../Scenarios"

func update_save_list() -> void:
	for save in $saves.get_children():
		var dir = Directory.new()
		if dir.dir_exists(Global.save_path + save.name):
			var savegame = File.new()
			if savegame.file_exists(Global.save_path + save.name + "/playerData.dat"): #Gets save data
				savegame.open(Global.save_path + save.name + "/playerData.dat",File.READ)
				var playerData = savegame.get_var()
				savegame.close()
				save.get_node("Label").text = "Player" if !playerData.has("player_name") else playerData["player_name"]
				if playerData.has("scenario"): #Loads scenario icon
					save.get_node("Icon").texture = scenarios.scenarios[playerData["scenario"]]["icon"]
				else:
					save.get_node("Icon").texture = scenarios.scenarios["sandbox"]["icon"]
			else:
				save.get_node("Label").text = "Save " + str(save.id + 1)
				save.get_node("Icon").texture = scenarios.scenarios["empty"]["icon"]
			save.get_node("stats").hide()
			save.get_node("delete").show()
		else:
			save.get_node("stats").show()
			save.get_node("Label").text = "Save " + str(save.id + 1)
			save.get_node("Icon").texture = scenarios.scenarios["empty"]["icon"]
			save.get_node("delete").hide()

func save_clicked(save : Object) -> void:
	selectedSave = save.name
	if Global.save_exists(save.name):
		start()
	else:
		hide()
		get_node("../character").open()
		$"../../Scenarios".scenario_btn_pressed("sandbox")

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
