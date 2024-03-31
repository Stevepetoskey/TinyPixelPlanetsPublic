extends Node

const CURRENTVER = "TU 4 Beta 8 (v0.4.0:8)"
const VER_NUMS = [0,4,0,8]
const ALLOW_VERSIONS = [
	[0,4,0,8]
]
const STABLE = false

var savegame = File.new() #file
var save_path = "user://" #place of the file
onready var tutorial_path = "res://data/Tutorial"
var currentSave : String
var new = true
var gameStart = true
var currentPlanet : int
var currentSystem : int
var currentSystemId : String
var playerData = {}
var playerName = ""
var blues = 0
var killCount = 0
var scenario = "sandbox"
var starterPlanetId : int
var godmode = false
var pause = false
var enemySpawning = true
var entitySpawning = true
var inTutorial = false
var meteorsAttacked = false
var globalGameTime : int = 0
var gameTimeTimer : Timer = Timer.new()
var default_bookmarks = [
	{"name":"Shop center","icon":"star","color":Color(0.39,0.58,0.92),"system_id":"3680641011042","planet_id":0}
	]
var bookmarks : Array= []

var gamerulesBase = {
	"can_leave_planet":true,
	"can_leave_system":true,
	"max_hp":50,
	"starting_hp":50,
	"custom_world_file":"",
	"custom_generation":"",
	"can_respawn":true,
}
var gamerules = {}

var lightColor = Color.white

var playerBase = {"skin":Color("F8DEC3"),"hair_style":"Short","hair_color":Color("debe99"),"sex":"Guy"}

signal loaded_data
signal screenshot

func _ready():
	gameTimeTimer.connect("timeout",self,"game_time_second")
	gameTimeTimer.autostart = true
	add_child(gameTimeTimer)

func _process(delta):
	if blues >= 1000 and !GlobalGui.completedAchievements.has("Economist 1"):
		GlobalGui.complete_achievement("Economist 1")
	elif blues >= 5000 and !GlobalGui.completedAchievements.has("Economist 2"):
		GlobalGui.complete_achievement("Economist 2")
	elif blues >= 10000 and !GlobalGui.completedAchievements.has("Economist 3"):
		GlobalGui.complete_achievement("Economist 3")
	if killCount >= 1 and !GlobalGui.completedAchievements.has("Exterminator 1"):
		GlobalGui.complete_achievement("Exterminator 1")
	elif killCount >= 10 and !GlobalGui.completedAchievements.has("Exterminator 2"):
		GlobalGui.complete_achievement("Exterminator 2")
	elif killCount >= 50 and !GlobalGui.completedAchievements.has("Exterminator 3"):
		GlobalGui.complete_achievement("Exterminator 3")
	elif killCount >= 100 and !GlobalGui.completedAchievements.has("Destroyer of worlds"):
		GlobalGui.complete_achievement("Destroyer of worlds")

func save_exists(saveId : String) -> bool:
	var dir = Directory.new()
	if dir.dir_exists(save_path + saveId):
		return true
	return false

func open_tutorial():
	pass #Broken for now (as of v0.4.0:5)
#	inTutorial = true
#	currentSave = "save4"
#	gameStart = true
#	new = false
#	var dir = Directory.new()
#	if dir.dir_exists(save_path + currentSave):
#		remove_recursive(save_path + currentSave)
#	dir.open(save_path)
#	dir.make_dir(currentSave)
#	dir.open(save_path + currentSave)
#	dir.make_dir("systems")
#	dir.make_dir("planets")
#	var file = File.new()
#	file.open("res://data/Tutorial/systems/3891944108.dat",File.READ)
#	var systemDat = file.get_var()
#	file.close()
#	file.open(save_path + currentSave + "/systems/3891944108.dat",File.WRITE)
#	file.store_var(systemDat)
#	file.close()
#	file.open("res://data/Tutorial/planets/3891944108_2.dat",File.READ)
#	var planetData = file.get_var()
#	file.close()
#	file.open(save_path + currentSave + "/planets/3891944108_2.dat",File.WRITE)
#	file.store_var(planetData)
#	file.close()
##	copy_directory_recursively("res://data/Tutorial/planets/",save_path + currentSave + "/planets")
##	copy_directory_recursively("res://data/Tutorial/systems/",save_path + currentSave + "/systems")
#	currentPlanet = 2
#	starterPlanetId = 2
#	enemySpawning = false
#	StarSystem.systemDat = load_system(3891944108)
#	StarSystem.load_system()

func open_save(saveId : String) -> void:
	inTutorial = false
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
			blues = playerData["blues"]
			killCount = 0 if !playerData.has("kill_count") else playerData["kill_count"]
			bookmarks = default_bookmarks.duplicate(true) if !playerData.has("bookmarks") else playerData["bookmarks"]
			currentPlanet = playerData["current_planet"]
			starterPlanetId = playerData["starter_planet"]
			gamerules = playerData["gamerules"]
			for rule in gamerulesBase: #Makes sure the gamerules are up to date
				if !gamerules.has(rule):
					gamerules[rule] = gamerulesBase[rule]
			godmode = playerData["godmode"]
			playerName = "Jerry" if !playerData.has("player_name") else playerData["player_name"]
			scenario = "sandbox" if !playerData.has("scenario") else  playerData["scenario"]
			globalGameTime = 0 if !playerData.has("game_time") else playerData["game_time"]
			meteorsAttacked = false if !playerData.has("misc_stats") else playerData["misc_stats"]["meteors_attacked"]
			StarSystem.landedPlanetTypes = [] if !playerData.has("landed_planet_types") else playerData["landed_planet_types"]
			GlobalGui.completedAchievements = [] if !playerData.has("achievements") else playerData["achievements"]
			StarSystem.systemDat = load_system(playerData["current_system"])
			StarSystem.load_system()
			new = false
		else:
			new_save(saveId)
	else:
		new_save(saveId)
	currentSave = saveId

func new_save(saveId : String):
	gamerules = gamerulesBase.duplicate(true)
	bookmarks = default_bookmarks.duplicate(true)
	meteorsAttacked = false
	match scenario:
		"temple":
			gamerules["can_leave_planet"] = false
			gamerules["custom_world_file"] = "temple"
		"meteor":
			gamerules["can_leave_planet"] = false
			gamerules["custom_generation"] = "meteor"
		"insane":
			gamerules["max_hp"] = 1
			gamerules["starting_hp"] = 1
			gamerules["can_respawn"] = false
	var dir = Directory.new()
	blues = 0
	killCount = 0
	StarSystem.landedPlanetTypes = []
	dir.open(save_path)
	dir.make_dir(saveId)
	dir.open(save_path + saveId)
	dir.make_dir("systems")
	dir.make_dir("planets")
	copy_directory_recursively("res://data/pre_made_planets/",save_path + saveId + "/planets")
	copy_directory_recursively("res://data/pre_made_systems/",save_path + saveId + "/systems")
	GlobalGui.completedAchievements = []
	globalGameTime = 0
	var _er = get_tree().change_scene("res://scenes/Main.tscn")

func new_planet() -> void:
	var _er = get_tree().change_scene("res://scenes/Main.tscn")
	yield(get_tree(),"idle_frame")
	new = true
	if savegame.file_exists(save_path + currentSave + "/planets/" + str(currentSystemId) + "_" + str(currentPlanet) + ".dat"):
		new = false
	emit_signal("loaded_data")

func save(saveType : String, saveData : Dictionary) -> void:
	#emit_signal("screenshot")
#	yield(get_tree(),"idle_frame")
#	var image = get_viewport().get_texture().get_data()
#	image.flip_y()
#	image.save_png(save_path + currentSave + "/icon.png")
	playerData["save_type"] = saveType
	playerData["achievements"] = GlobalGui.completedAchievements
	playerData["kill_count"] = killCount
	playerData["landed_planet_types"] = StarSystem.landedPlanetTypes
	playerData["scenario"] = scenario
	playerData["player_name"] = playerName
	playerData["gamerules"] = gamerules
	playerData["game_time"] = globalGameTime
	playerData["version"] = VER_NUMS
	playerData["bookmarks"] = bookmarks
	match saveType:
		"planet":
			playerData = saveData["player"]
			playerData["gamerules"] = gamerules
			playerData["scenario"] = scenario
			playerData["player_name"] = playerName
			playerData["skin"] = playerBase["skin"];playerData["hair_color"] = playerBase["hair_color"];playerData["hair_style"] = playerBase["hair_style"]
			playerData["sex"] = playerBase["sex"]
			playerData["starter_planet"] = starterPlanetId
			playerData["godmode"] = godmode
			playerData["blues"] = blues
			playerData["kill_count"] = killCount
			playerData["landed_planet_types"] = StarSystem.landedPlanetTypes
			playerData["misc_stats"]["meteors_attacked"] = meteorsAttacked
			playerData["game_time"] = globalGameTime
			playerData["version"] = VER_NUMS
			playerData["bookmarks"] = bookmarks
			savegame.open(save_path + currentSave + "/planets/" + str(currentSystemId) + "_" + str(currentPlanet) + ".dat",File.WRITE)
			savegame.store_var(saveData["planet"])
			savegame.close()
			savegame.open(save_path + currentSave + "/systems/" + str(currentSystemId) + ".dat",File.WRITE)
			savegame.store_var(saveData["system"])
			savegame.close()
		"system":
			playerData["pos"] = saveData["player"]["pos"]
			savegame.open(save_path + currentSave + "/systems/" + str(currentSystemId) + ".dat",File.WRITE)
			savegame.store_var(saveData["system"])
			savegame.close()
	savegame.open(save_path + currentSave + "/playerData.dat",File.WRITE)
	savegame.store_var(playerData)
	savegame.close()
	print("Saved game!")

func save_system() -> void:
	savegame.open(save_path + currentSave + "/systems/" + str(currentSystemId) + ".dat",File.WRITE)
	savegame.store_var(StarSystem.get_system_data())
	savegame.close()
	print("Saved system!")

func load_player() -> Dictionary:
	var data : Dictionary
	data = load_data(save_path + currentSave + "/playerData.dat")
	return data

func load_system(systemId : String) -> Dictionary:
	var data : Dictionary
	data = load_data(save_path + currentSave + "/systems/" + systemId + ".dat")
	return data

func load_planet(systemId : String, planetId : int) -> Dictionary:
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

func find_bookmark(systemId : String, planetId : int) -> int:
	for bookmark in bookmarks:
		if bookmark["system_id"] == systemId and bookmark["planet_id"] == planetId:
			return bookmarks.find(bookmark)
	return -1

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

func copy_directory_recursively(p_from : String, p_to : String) -> void:
	var directory = Directory.new()
	if not directory.dir_exists(p_to):
		directory.make_dir_recursive(p_to)
	if directory.open(p_from) == OK:
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while (file_name != "" and file_name != "." and file_name != ".."):
			if directory.current_is_dir():
				copy_directory_recursively(p_from + "/" + file_name, p_to + "/" + file_name)
			else:
				directory.copy(p_from + "/" + file_name, p_to + "/" + file_name)
			file_name = directory.get_next()
	else:
		push_warning("Error copying " + p_from + " to " + p_to)

func game_time_second():
	globalGameTime += 1
