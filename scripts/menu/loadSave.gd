extends Control

var selectedSave = ""

@onready var scenarios = $"../../Scenarios"

func update_save_list() -> void:
	for save in $saves.get_children():
		if DirAccess.dir_exists_absolute(Global.save_path + save.name) and FileAccess.file_exists(Global.save_path + save.name + "/playerData.dat"):
			var savegame = FileAccess.open(Global.save_path + save.name + "/playerData.dat",FileAccess.READ)
			var playerData = savegame.get_var()
			if typeof(playerData) == TYPE_DICTIONARY:
				save.get_node("Label").text = "Player" if typeof(playerData) != TYPE_DICTIONARY or !playerData.has("player_name") else playerData["player_name"]
				if playerData.has("version") and Global.ALLOW_VERSIONS.has(playerData["version"]):
					save.disabled = false
					save.get_node("stats").text = "Ver: " + str(playerData["version"][0]) + "." + str(playerData["version"][1]) + "." + str(playerData["version"][2]) + ((":" + str(playerData["version"][3]) if playerData["version"][3] > 0 else ""))
					save.get_node("stats").set("theme_override_colors/font_color",Color("c4c4c4"))
				else:
					save.disabled = true
					save.get_node("stats").text = "Ver: Unkown" if !playerData.has("version") else ("Ver: " + str(playerData["version"][0]) + "." + str(playerData["version"][1]) + "." + str(playerData["version"][2]) + ":" + str(playerData["version"][3]))
					save.get_node("stats").set("theme_override_colors/font_color",Color.RED)
				if playerData.has("scenario"): #Loads scenario icon
					save.get_node("Icon").texture = scenarios.scenarios[playerData["scenario"]]["icon"]
				else:
					save.get_node("Icon").texture = scenarios.scenarios["sandbox"]["icon"]
			else:
				save.disabled = true
				save.get_node("Label").text = "Player"
				save.get_node("stats").text = "Ver: incompatible"
				save.get_node("stats").set("theme_override_colors/font_color",Color.RED)
				save.get_node("Icon").texture = scenarios.scenarios["empty"]["icon"]
			save.get_node("delete").show()
		else:
			save.disabled = false
			save.get_node("stats").text = "empty"
			save.get_node("stats").set("theme_override_colors/font_color",Color("c4c4c4"))
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
	await get_node("../../AnimationPlayer").animation_finished
	GlobalAudio.change_mode("game")
	if tutorial:
		Global.open_tutorial()
	else:
		Global.open_save(selectedSave)
