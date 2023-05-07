extends Node2D

const PLANET = preload("res://assets/planetData.tscn")
const MAX_SPACE_CHECK = 50

var sizeTypes = {
	small = 0,
	medium = 1,
	large = 2,
	max_size = 3
}

var planetData = {"small_earth":{"texture":preload("res://textures/planets/terra.png"),"size":sizeTypes.small,"type":"terra"},
	"small_desert":{"texture":preload("res://textures/planets/desert.png"),"size":sizeTypes.small,"type":"desert"},
	"small_mud":{"texture":preload("res://textures/planets/mud.png"),"size":sizeTypes.small,"type":"mud"},
	"small_stone":{"texture":preload("res://textures/planets/stone.png"),"size":sizeTypes.small,"type":"stone"},
	"small_snow":{"texture":preload("res://textures/planets/snow.png"),"size":sizeTypes.small,"type":"snow"},
	"small_snow_terra":{"texture":preload("res://textures/planets/snow_terra.png"),"size":sizeTypes.small,"type":"snow_terra"},
	"snow":{"texture":preload("res://textures/planets/snowMedium.png"),"size":sizeTypes.medium,"type":"snow"},
	"snow_terra":{"texture":preload("res://textures/planets/snow_terraMedium.png"),"size":sizeTypes.medium,"type":"snow_terra"},
	"earth":{"texture":preload("res://textures/planets/terraMedium.png"),"size":sizeTypes.medium,"type":"terra"},
	"desert":{"texture":preload("res://textures/planets/desertMedium.png"),"size":sizeTypes.medium,"type":"desert"},
	"mud":{"texture":preload("res://textures/planets/mudMedium.png"),"size":sizeTypes.medium,"type":"mud"},
	"stone":{"texture":preload("res://textures/planets/StoneMedium.png"),"size":sizeTypes.medium,"type":"stone"},
	"gas1":{"texture":preload("res://textures/planets/gas1.png"),"size":sizeTypes.large,"type":"gas1"},
	"gas2":{"texture":preload("res://textures/planets/gas2.png"),"size":sizeTypes.large,"type":"gas2"},
	"gas3":{"texture":preload("res://textures/planets/gas3.png"),"size":sizeTypes.large,"type":"gas3"},
}

var sizeData = { #Normal moon chance: 10,50,95
	sizeTypes.small:{"moon_chance":10,"distance":range(40,80),"radius":7,"world_size":Vector2(128,32)},
	sizeTypes.medium:{"moon_chance":60,"distance":range(50,150),"radius":14,"world_size":Vector2(256,32)},
	sizeTypes.large:{"moon_chance":120,"distance":range(60,240),"radius":28},
}

var starData = {"M-type":{"min_distance":100,"habital":[],"max_distance":800},
	"K-type":{"min_distance":120,"habital":range(350,550),"max_distance":1100},
	"G-type":{"min_distance":160,"habital":range(600,800),"max_distance":1300},
	"B-type":{"min_distance":200,"habital":range(700,1000),"max_distance":1600},
}

var currentStar
var currentStarName
var currentSeed
var currentStarData

var systemDat = {}
var visitedPlanets = []

var planetReady = false

signal planet_ready
signal found_system

func start_game():
	print("---start game---")
	if Global.new:
		new()
		yield(self,"found_system")
		Global.currentPlanet = find_planet("type","terra").id
		Global.starterPlanetId = Global.currentPlanet
		print("Current Planet: ", find_planet_id(Global.currentPlanet).pName)
	planetReady = true
	print("---Planet Ready---")
	emit_signal("planet_ready")

func start_space():
	print("going into space")
	var _er = get_tree().change_scene("res://scenes/PlanetSelect.tscn")

func land(planet : int):
	Global.currentPlanet = planet
	Global.new_planet()

func new():
	print("new")
	randomize()
	var Seed = randi()
	new_system(Seed)
	yield(get_tree(),"idle_frame")
	while !search_system("type").has("terra"):
		Seed = randi()
		new_system(Seed)
		yield(get_tree(),"idle_frame")
	print("--- Star System ", currentStarName, " ---")
	print("Seed: ", currentSeed)
	print("Star: ", currentStar)
	print("Num Of Planets: ", get_orbiting_bodies($stars).size())
	print("Num Of Bodies: ", $system.get_child_count() + 1)
	print("Planets:")
	for planet in $system.get_children():
		print(planet.pName + " Type: " + planet.type["type"])
	emit_signal("found_system")

func new_system(systemSeed : int, loaded = false):
	print("new System")
	print(systemDat)
	seed(systemSeed)
	currentSeed = systemSeed
	for child in $system.get_children():
		child.queue_free()
		$system.remove_child(child)
	yield(get_tree(),"idle_frame")
	currentStar = ["M-type","K-type","G-type","B-type"][randi()%4]
	currentStarName = create_name(currentSeed)
	currentStarData = starData[currentStar]
	var amountOfPlanets = randi() % 20 + 1
	print("Before: ",get_system_bodies())
	for _i in range(amountOfPlanets):
		create_planet()

func create_planet(orbitBody = $stars, maxSize = sizeTypes.max_size, orbitingSize = 0) -> void:
	#randomize()
	var planet = PLANET.instance()
	planet.id = get_system_bodies().size()
	planet.hasAtmosphere = bool(randi() % 2)
	
	#Determines planet type
	var planetType
	var planets = []# = ["small_desert","small_mud","small_stone","desert","mud","stone","gas1","gas2"]
	for planetDat in planetData:
		if (planetData[planetDat]["size"] < maxSize or (maxSize == 0 and planetData[planetDat]["size"] == 0)) and !["terra","snow","snow_terra"].has(planetData[planetDat]["type"]):
			planets.append(planetData[planetDat])
	planets.shuffle()
	planetType = planets[0]
	planet.type = planetType
	#Gets orbit data
	if orbitBody == $stars:
		var i = 0
		while true:
			i += 1
			planet.orbitalDistance = int(rand_range(currentStarData["min_distance"],currentStarData["max_distance"]))
			if is_clear_space(planet,orbitBody):
				break
			if i == MAX_SPACE_CHECK:
				return
	else:
		var i = 0
		while true:
			i += 1
			planet.orbitalDistance = sizeData[orbitingSize]["distance"][randi() % sizeData[orbitingSize]["distance"].size()]
			if is_clear_space(planet,orbitBody):
				break
			if i == MAX_SPACE_CHECK:
				return
		planet.modulate = Color.red
	planet.orbitingBody = orbitBody
	planet.orbitalSpeed = int(rand_range(6,12))
	planet.rotationSpeed = int(rand_range(1,8))
	planet.currentOrbit = deg2rad(randi() % 360)
	planet.currentRot = deg2rad(randi() % 360)
	if !systemDat.empty() and systemDat["planets"].has(planet.id):
		planet.currentOrbit = systemDat["planets"][planet.id]["current_orbit"]
		planet.currentRot = systemDat["planets"][planet.id]["current_rot"]
	
	#Checks if habitable
	var size = "" if planetType["size"] > sizeTypes.small else "small_"
	if currentStarData["habital"].has(abs(planet.orbitalDistance-orbitBody.orbitalDistance)) and randi()%5 == 1:
		planet.type = planetData[size + "earth"]
		planet.hasAtmosphere = true
	elif !currentStarData["habital"].empty() and abs(planet.orbitalDistance-orbitBody.orbitalDistance) > currentStarData["habital"][currentStarData["habital"].size()-1]:
		if randi() % 3 ==1:
			planet.type = planetData[size + "snow"]
			planet.hasAtmosphere = true
		elif randi() % 4 ==1:
			planet.type = planetData[size + "snow_terra"]
			planet.hasAtmosphere = true
	
	$system.add_child(planet)
	#Creates moons
	if orbitBody == $stars:
		planet.pName = currentStarName + " " + {0:"a",1:"b",2:"c",3:"d",4:"e",5:"f",6:"g",7:"h",8:"i",9:"j",10:"k",11:"l"}[get_orbiting_bodies(orbitBody).size()]
		size = sizeData[planetType["size"]]
		var chance = size["moon_chance"]
		while chance > 0:
			if randi() % 100 < chance:
				chance -= 10
				create_planet(planet,planetType["size"],planetType["size"])
			else:
				break
	else:
		var num = str((get_orbiting_bodies(orbitBody).size() + 1)/10.0)
		num[0] = orbitBody.pName[orbitBody.pName.length() -1]
		planet.pName = currentStarName + " " + num

func is_clear_space(planetSelf : Object, orbitingBody : Object) -> bool:
	if !get_orbiting_bodies(orbitingBody).empty():
		for planet in get_orbiting_bodies(orbitingBody):
			if planet != self:
				var planetMoonArea = sizeData[planet.type["size"]]["distance"]
				planetMoonArea = planetMoonArea[planetMoonArea.size()-1] / (int(orbitingBody != $stars)*2 + 1)
				var selfMoonArea = sizeData[planetSelf.type["size"]]["distance"]
				selfMoonArea = selfMoonArea[selfMoonArea.size()-1] / (int(orbitingBody != $stars)*2 + 1)
				if !(planet.orbitalDistance + planetMoonArea < planetSelf.orbitalDistance - selfMoonArea or planet.orbitalDistance - planetMoonArea > planetSelf.orbitalDistance + selfMoonArea):
					return false
		return true
	else:
		return true

func get_orbiting_bodies(base : Object) -> Array:
	var inOrbit = []
	for planet in $system.get_children():
		if planet.orbitingBody == base:
			inOrbit.append(planet)
	return inOrbit

func get_system_bodies() -> Array:
	return $system.get_children()

func search_system(dataType : String) -> Array:
	var data = []
	var planets = get_system_bodies()
	for planet in planets:
		match dataType:
			"type","size","texture":
				data.append(planet.type[dataType])
			"distance":
				data.append(planet.orbitalDistance)
			"orbiting":
				data.append(planet.orbitingBody)
	return data

func find_planet(dataType : String, parameter : String) -> Object:
	var planets = get_system_bodies()
	for planet in planets:
		var data
		match dataType:
			"type","size","texture":
				data = planet.type[dataType]
			"distance":
				data = planet.orbitalDistance
			"orbiting":
				data = planet.orbitingBody
		if data == parameter:
			print(planet.pName)
			return planet
	return null

func find_planet_id(id : int, debug = false) -> Object:
	var planets = get_system_bodies()
	for planet in planets:
		if debug:
			print(planet.id)
		if planet.id == id:
			return planet
	return null

func create_name(systemSeed : int) -> String:
	var beforeLen = int(rand_range(2,6))
	var convertDic = {"0":"p","1":"a","2":"l","3":"c","4":"d","5":"e","6":"m","7":"g","8":"s","9":"i","10":"o","20":" ","30":"deg","40":"zok"}
	var string = str(systemSeed)
	if beforeLen > string.length():
		beforeLen = string.length()
	var starName = ""
	for num in range(beforeLen):
		if num == beforeLen-1 or !convertDic.has(string[num] + string[num+1]):
			var letter = convertDic[string[num]]
			if num == 0:
				letter = letter.capitalize()
			starName += letter
		else:
			starName += convertDic[string[num]]
	starName += "-" + string.substr(beforeLen)
	return starName

func get_system_data() -> Dictionary:
	var data = {"star":currentStar,"seed":currentSeed,"planets":{},"visited":visitedPlanets}
	var planets = get_system_bodies()
	for planet in planets:
		data["planets"][planet.id] = {"current_orbit":planet.currentOrbit,"current_rot":planet.currentRot}
	return data

func get_current_world_size() -> Vector2:
	print("After: ",get_system_bodies())
	return sizeData[find_planet_id(Global.currentPlanet,true).type["size"]]["world_size"]
