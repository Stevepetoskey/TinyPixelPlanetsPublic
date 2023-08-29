extends Node

const CURRENTVER = "TU 2 Beta 2"
const STABLE = false

var savegame = File.new() #file
var save_path = "user://" #place of the file
var currentSave : String
var new = true
var gameStart = true
var currentPlanet : int
var playerData
var starterPlanetId : int

var playerBase = {"skin":Color("F8DEC3"),"hair_style":"Short","hair_color":Color("debe99"),"sex":"Guy"}

signal loaded_data
signal screenshot

func save_exists(saveId : String) -> bool:
	var dir = Directory.new()
	if dir.dir_exists(save_path + saveId):
		return true
	return false

func open_save(saveId : String) -> void:
	currentSave = saveId
	gameStart = true
	new = true
	var dir = Directory.new()
	var file = File.new()
	if dir.dir_exists(save_path + saveId):
		if file.file_exists(save_path + saveId + "/playerData.dat"):
			savegame.open(save_path + saveId + "/playerData.dat",File.READ)
			playerData = savegame.get_var()
			savegame.close()
			currentPlanet = playerData["current_planet"]
			StarSystem.systemDat = load_system(playerData["current_system"])
			StarSystem.visitedPlanets = StarSystem.systemDat["visited"]
			StarSystem.new_system(playerData["current_system"],true)
			new = false
		else:
			remove_recursive(save_path + saveId)
			dir.open(save_path)
			dir.make_dir(saveId)
			dir.open(save_path + saveId)
			dir.make_dir("systems")
			dir.make_dir("planets")
	else:
		dir.open(save_path)
		dir.make_dir(saveId)
		dir.open(save_path + saveId)
		dir.make_dir("systems")
		dir.make_dir("planets")
	currentSave = saveId

func new_planet() -> void:
	var _er = get_tree().change_scene("res://scenes/Main.tscn")
	yield(get_tree(),"idle_frame")
	new = true
	if savegame.file_exists(save_path + currentSave + "/planets/" + str(StarSystem.currentSeed) + "_" + str(currentPlanet) + ".dat"):
		new = false
		print("has file")
	emit_signal("loaded_data")

func save(saveData : Dictionary) -> void:
	emit_signal("screenshot")
	yield(get_tree(),"idle_frame")
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png(save_path + currentSave + "/icon.png")
	playerData = saveData["player"]
	playerData["skin"] = playerBase["skin"];playerData["hair_color"] = playerBase["hair_color"];playerData["hair_style"] = playerBase["hair_style"]
	playerData["sex"] = playerBase["sex"]
	playerData["starter_planet"] = starterPlanetId
	savegame.open(save_path + currentSave + "/playerData.dat",File.WRITE)
	savegame.store_var(saveData["player"])
	savegame.close()
	savegame.open(save_path + currentSave + "/planets/" + str(StarSystem.currentSeed) + "_" + str(currentPlanet) + ".dat",File.WRITE)
	savegame.store_var(saveData["planet"])
	savegame.close()
	savegame.open(save_path + currentSave + "/systems/" + str(StarSystem.currentSeed) + ".dat",File.WRITE)
	savegame.store_var(saveData["system"])
	savegame.close()
	print("Saved game!")

func load_player() -> Dictionary:
	var data : Dictionary
	data = load_data(save_path + currentSave + "/playerData.dat")
	return data

func load_system(systemId : int) -> Dictionary:
	var data : Dictionary
	data = load_data(save_path + currentSave + "/systems/" + str(systemId) + ".dat")
	return data

func load_planet(systemId : int, planetId : int) -> Dictionary:
	var data : Dictionary
	data = load_data(save_path + currentSave + "/planets/" + str(systemId) + "_" + str(planetId) + ".dat")
	return data

func load_data(path : String) -> Dictionary:
	var lData : Dictionary
	if savegame.file_exists(path):
		savegame.open(path,File.READ)
		lData = savegame.get_var()
		savegame.close()
	else:
		lData = {}
	return lData

func delete(dir : String) -> void:
	var directory = Directory.new()
	if directory.dir_exists(save_path + dir):
		remove_recursive(save_path + dir)

func remove_recursive(path): #Credit to davidepesce.com for this function. It deletes all the files in the main file, which allows it to delete the main one safely
	var directory = Directory.new()
	
	# Open directory
	var error = directory.open(path)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)
