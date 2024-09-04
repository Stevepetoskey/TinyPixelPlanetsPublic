extends Node2D

const PLANET = preload("res://assets/planetData.tscn")
const MAX_SPACE_CHECK = 50
const SECTOR_SIZE = Vector2(568,568)
const GALAXY_SIZE = Vector2(1000,1000)
const SECTOR_STAR_RANGE = [40,60]

var sizeTypes = {
	small = 0,
	medium = 1,
	large = 2,
	max_size = 3
}

var FirstStarName = [
	"Theta",
	"Alpha",
	"Eta",
	"Zeta",
	"Epsilon",
	"Xi",
	"Beta",
	"Gamma",
	"Rho",
	"Chi",
	"Sigma",
	"Nu",
	"Kappa",
	"Delta",
	"Lambda",
	"Mu",
	"Iota",
	"Omicron",
	"Pi"
]

var SecondStarName = [
	"Eridani",
	"Cassiopeiae",
	"Crucis",
	"Cancri",
	"Leonis",
	"Canis",
	"Majoris",
	"Andromedae",
	"Tauri",
	"Aurigae",
	"Aquarii",
	"Cygni",
	"Corvi",
	"Ursae",
	"Cephei",
	"Capricorni",
	"Pegasi",
	"Leonis",
	"Persei",
	"Geminorum",
	"Minoris",
	"Bootis",
	"Crateris",
	"Centauri",
	"Gruis",
	"Sagittarii",
	"Orionis",
	"Scorpii",
	"Hydrae",
	"Coronae",
	"Borealis",
	"Piscium",
	"Draconis",
	"Aquilae",
	"Serpentis",
	"Phoenicis",
	"Trianguli",
	"Virginis",
	"Aimunigos",
	"Suss",
	"Dulovc"
]

var weatherEvents = {
	"terra":["rain","showers"],
	"desert":["none"],
	"mud":["none"],
	"exotic":["rain","showers"],
	"stone":["none"],
	"snow":["snow","blizzard"],
	"snow_terra":["snow","blizzard"],
	"asteroids":["none"],
	"ocean":["rain","showers"],
	"grassland":["rain"],
	"scorched":["none"],
	"frigid":["snow","blizzard"]
}

var typeNames = {
	"terra":"Terra",
	"desert":"Desert",
	"mud":"Mud",
	"exotic":"Exotic",
	"stone":"Stone",
	"snow":"Snow",
	"snow_terra":"Snowy terra",
	"gas1":"Gas giant",
	"gas2":"Gas giant",
	"gas3":"Gas giant",
	"asteroids":"Asteroids",
	"ocean":"Ocean",
	"grassland":"Grassland",
	"scorched":"Scorched",
	"frigid":"Frigid"
}

var hostileSpawn = {
	"terra":["slorg"],
	"desert":["slorg"],
	"mud":[],
	"exotic":[],
	"stone":["rockius"],
	"snow":[],
	"snow_terra":["slorg"],
	"asteroids":["space_squid"],
	"ocean":[],
	"grassland":["slorg"],
	"scorched":[],
	"frigid":[],
}

var creatureSpawn = {
	"terra":["blue_jay"],
	"desert":[],
	"mud":[],
	"exotic":[],
	"stone":[],
	"snow":[],
	"snow_terra":["stellar_pig","blue_jay"],
	"asteroids":[],
	"ocean":[],
	"grassland":["blue_jay"],
	"scorched":[],
	"frigid":[],
}

var sizeNames = {
	0:"Small",
	1:"Medium",
	2:"Large",
	3:"Giant"
}

var planetData = {"small_earth":{"texture":preload("res://textures/planets/terra.png"),"size":sizeTypes.small,"type":"terra"},
	"small_desert":{"texture":preload("res://textures/planets/desert.png"),"size":sizeTypes.small,"type":"desert"},
	"small_mud":{"texture":preload("res://textures/planets/mud.png"),"size":sizeTypes.small,"type":"mud"},
	"small_exotic":{"texture":preload("res://textures/planets/exotic.png"),"size":sizeTypes.small,"type":"exotic"},
	"small_stone":{"texture":preload("res://textures/planets/stone.png"),"size":sizeTypes.small,"type":"stone"},
	"small_snow":{"texture":preload("res://textures/planets/snow.png"),"size":sizeTypes.small,"type":"snow"},
	"small_snow_terra":{"texture":preload("res://textures/planets/snow_terra.png"),"size":sizeTypes.small,"type":"snow_terra"},
	"snow":{"texture":preload("res://textures/planets/snowMedium.png"),"size":sizeTypes.medium,"type":"snow"},
	"snow_terra":{"texture":preload("res://textures/planets/snow_terraMedium.png"),"size":sizeTypes.medium,"type":"snow_terra"},
	"earth":{"texture":preload("res://textures/planets/terraMedium.png"),"size":sizeTypes.medium,"type":"terra"},
	"desert":{"texture":preload("res://textures/planets/desertMedium.png"),"size":sizeTypes.medium,"type":"desert"},
	"mud":{"texture":preload("res://textures/planets/mudMedium.png"),"size":sizeTypes.medium,"type":"mud"},
	"exotic":{"texture":preload("res://textures/planets/exoticMedium.png"),"size":sizeTypes.medium,"type":"exotic"},
	"stone":{"texture":preload("res://textures/planets/StoneMedium.png"),"size":sizeTypes.medium,"type":"stone"},
	"gas1":{"texture":preload("res://textures/planets/gas1.png"),"size":sizeTypes.large,"type":"gas1"},
	"gas2":{"texture":preload("res://textures/planets/gas2.png"),"size":sizeTypes.large,"type":"gas2"},
	"gas3":{"texture":preload("res://textures/planets/gas3.png"),"size":sizeTypes.large,"type":"gas3"},
	"asteroids":{"texture":preload("res://textures/planets/asteroids.png"),"size":sizeTypes.small,"type":"asteroids"},
	"small_ocean":{"texture":preload("res://textures/planets/ocean.png"),"size":sizeTypes.small,"type":"ocean"},
	"ocean":{"texture":preload("res://textures/planets/oceanMedium.png"),"size":sizeTypes.medium,"type":"ocean"},
	"small_grassland":{"texture":preload("res://textures/planets/grassland.png"),"size":sizeTypes.small,"type":"grassland"},
	"grassland":{"texture":preload("res://textures/planets/grasslandMedium.png"),"size":sizeTypes.medium,"type":"grassland"},
	"small_scorched":{"texture":preload("res://textures/planets/scorched.png"),"size":sizeTypes.small,"type":"scorched"},
	"scorched":{"texture":preload("res://textures/planets/scorchedMedium.png"),"size":sizeTypes.medium,"type":"scorched"},
	"small_frigid":{"texture":preload("res://textures/planets/frigid.png"),"size":sizeTypes.small,"type":"frigid"},
	"frigid":{"texture":preload("res://textures/planets/frigidMedium.png"),"size":sizeTypes.medium,"type":"frigid"},
	#"commet":{"texture":preload("res://textures/planets/commet.png"),"size":sizeTypes.large,"type":"commet"},
}

var sizeData = { #Normal moon chance: 10,50,95 (40,80), (50,150), (60,240)
	sizeTypes.small:{"moon_chance":20,"distance":range(40,80),"radius":7,"world_size":Vector2(128,64)},
	sizeTypes.medium:{"moon_chance":70,"distance":range(50,150),"radius":14,"world_size":Vector2(256,64)},
	sizeTypes.large:{"moon_chance":150,"distance":range(60,240),"radius":28},
}

var starData = {"M-type":{"min_distance":100,"habital":[],"max_distance":800},
	"K-type":{"min_distance":120,"habital":range(350,800),"max_distance":1100},
	"G-type":{"min_distance":160,"habital":range(550,900),"max_distance":1300},
	"B-type":{"min_distance":200,"habital":range(600,1300),"max_distance":1600},
}

var currentStar
var currentStarName
var currentSeed
var currentStarData

var systemDat = {}
var visitedPlanets = []
var landedPlanetTypes = []

var loadFromGalaxy = false
var planetReady = false

signal planet_ready
signal found_system
signal leaving_planet
signal leaving_system
signal entering_system
signal landing_planet
signal start_meteors

func start_game():
	print("---start game---")
	if Global.new:
		new_game()
		await self.found_system
		Global.currentPlanet = find_planet("type","terra").id
		Global.starterPlanetId = Global.currentPlanet
		Global.playerData["original_system"] = Global.currentSystemId
		Global.playerData["original_planet"] = Global.currentPlanet
		#if Global.scenario == "meteor": #Adds the commet if meteor scenario
			#var commet = PLANET.instantiate()
			#commet.id = get_system_bodies().size()
			#commet.type = {"texture":preload("res://textures/planets/commet.png"),"size":sizeTypes.large,"type":"commet"}
			#commet.hasAtmosphere = false
			#commet.orbitalDistance = 500
			#commet.orbitingBody = find_planet_id(Global.currentPlanet)
			#commet.orbitalSpeed = 0
			#commet.rotationSpeed = 0
			#commet.currentOrbit = deg_to_rad(randi() % 360)
			#commet.currentRot = deg_to_rad(randi() % 360)
			#$system.add_child(commet)
		print("Current Planet: ", find_planet_id(Global.currentPlanet).pName)
	planetReady = true
	print("---Planet Ready---")
	emit_signal("planet_ready")

func start_space():
	print("going into space")
	GlobalGui.complete_achievement("The mechanic")
	emit_signal("leaving_planet")
	var _er = get_tree().change_scene_to_file("res://scenes/PlanetSelect.tscn")

func land(planet : int):
	Global.currentPlanet = planet
	Global.new_planet()
	var planetType = find_planet_id(planet).type["type"]
	if !landedPlanetTypes.has(planetType):
		landedPlanetTypes.append(planetType)
		print("Found new planet type!")
		print("explored planet type count: ",landedPlanetTypes.size())
		if landedPlanetTypes.size() >= 3:
			GlobalGui.complete_achievement("Explorer 1")
		if landedPlanetTypes.size() >= 6:
			GlobalGui.complete_achievement("Explorer 2")
		if landedPlanetTypes.size() >= 9:
			GlobalGui.complete_achievement("Explorer 3")
	GlobalGui.complete_achievement("Interplanetary")
	emit_signal("landing_planet")

func open_star_system(systemSeed : int,systemId : String, fromGalaxy := false):
	emit_signal("entering_system")
	loadFromGalaxy = fromGalaxy
	Global.currentSystem = systemSeed
	Global.currentSystemId = systemId
	print("GIVEN SYSTEM ID: ",systemId)
	if FileAccess.file_exists(Global.save_path + Global.currentSave + "/systems/" + systemId + ".dat"):
		systemDat = Global.load_system(systemId)
		print("Loading system")
		load_system(true)
	else:
		print("Creating new system")
		new_system(systemSeed)
		var _er = get_tree().change_scene_to_file("res://scenes/PlanetSelect.tscn")
		print("Entering system ",systemSeed)

func leave_star_system():
	Global.currentPlanet = -1
	Global.save_system()
	visitedPlanets.clear()
	emit_signal("leaving_system")
	var _er = get_tree().change_scene_to_file("res://scenes/Galaxy.tscn")
	print("Leaving system ",Global.currentSystem)

func new_game():
	visitedPlanets.clear()
	var foundSeed = false
	while !foundSeed:
		var seedX = str(snapped(int(randf_range(0,SECTOR_SIZE.x*GALAXY_SIZE.x)),SECTOR_SIZE.x))
		var seedY = str(snapped(int(randf_range(0,SECTOR_SIZE.y*GALAXY_SIZE.y)),SECTOR_SIZE.y))
		while seedY.length() < 6:
			seedY = "0" + seedY
		var sectorSeed = int(seedX + seedY)
		while seedX.length() < 6:
			seedX = "0" + seedX
		seed(sectorSeed)
		var starAmount = int(randf_range(SECTOR_STAR_RANGE[0],SECTOR_STAR_RANGE[1]))
		for i in range(starAmount):
			print("seeds")
			print(seedX)
			print(seedY)
			new_system(int(seedX + seedY + str(i)))
			await get_tree().process_frame
			if search_system("type").has("terra"):
				foundSeed = true
				Global.currentSystem = currentSeed
				Global.currentSystemId = seedX + seedY + str(i)
				break
	print("--- Star System ", currentStarName, " ---")
	print("Seed: ", currentSeed)
	print("Star: ", currentStar)
	print("Num Of Planets: ", get_orbiting_bodies($stars).size())
	print("Num Of Bodies: ", $system.get_child_count() + 1)
	print("Planets:")
	for planet in $system.get_children():
		print(planet.pName + " Type: " + planet.type["type"])
	emit_signal("found_system")

func load_system(entering = false, teleporting := false):
	get_tree().change_scene_to_file("res://scenes/loading.tscn")
	await get_tree().create_timer(3.0).timeout
	visitedPlanets.clear()
	Global.currentSystemId = systemDat["system_id"]
	Global.currentSystem = systemDat["system_seed"]
	if ["planet","system"].has(Global.playerData["save_type"]) or entering:
		GlobalAudio.currentMusic = "regular"
		print(Global.currentSystemId)
		for child in $system.get_children():
			child.queue_free()
			$system.remove_child(child)
		await get_tree().process_frame
		currentStarName = systemDat["system_name"]
		currentSeed = systemDat["system_seed"]
		currentStar = systemDat["star_type"]
		currentStarData = starData[currentStar]
		visitedPlanets = systemDat["visited_planets"]
		print(visitedPlanets)
		for id in systemDat["planets"]:
			var planetDat = systemDat["planets"][id]
			var planet = PLANET.instantiate()
			if planetDat["planet_type"] == "fridged":
				planetData["planet_type"] = "frigid"
			planet.id = id
			planet.hasAtmosphere = planetDat["has_atmosphere"]
			match planetDat["planet_type"]:
				"commet":
					planet.type = {"texture":preload("res://textures/planets/commet.png"),"size":sizeTypes.large,"type":"commet"}
				_:
					planet.type = planetData[look_up_planet_data(planetDat["planet_type"],planetDat["planet_size"])]
			planet.orbitalDistance = planetDat["orbit_distance"]
			planet.orbitingBody = $stars if planetDat["orbiting_body"] == -1 else find_planet_id(planetDat["orbiting_body"])
			planet.orbitalSpeed = planetDat["orbit_speed"]
			planet.rotationSpeed = planetDat["rotation_speed"]
			planet.currentOrbit = planetDat["current_orbit"]
			planet.currentRot = planetDat["current_rot"]
			planet.pName = planetDat["planet_name"]
			planet.pDesc = planetDat["planet_desc"]
			$system.add_child(planet)
		match Global.playerData["save_type"]:
			"planet":
				if teleporting:
					Global.new_planet()
				else:
					var _er = get_tree().change_scene_to_file("res://scenes/Main.tscn")
			"system","galaxy":
				print("entering system final")
				var _er = get_tree().change_scene_to_file("res://scenes/PlanetSelect.tscn")
	else:
		GlobalAudio.currentMusic = "space"
		var _er = get_tree().change_scene_to_file("res://scenes/Galaxy.tscn")

func quick_system_check(systemSeed : int) -> Dictionary:
	seed(systemSeed)
	var FSN = FirstStarName.duplicate()
	var SSN = SecondStarName.duplicate()
	FSN.shuffle()
	SSN.shuffle()
	var starName : String
	if randi() % 5 < 3:
		starName = FSN[0] + " "
	starName +=  SSN[0]
	if randi() % 5 < 2:
		starName += " " + SSN[1]
	var quickData = {"star":["M-type","K-type","G-type","B-type"][randi()%4]}
	return quickData

func new_system(systemSeed : int):
	print("new System")
	seed(systemSeed)
	var FSN = FirstStarName.duplicate()
	var SSN = SecondStarName.duplicate()
	FSN.shuffle()
	SSN.shuffle()
	var starName : String
	if randi() % 5 < 3:
		starName = FSN[0] + " "
	starName +=  SSN[0]
	if randi() % 5 < 2:
		starName += " " + SSN[1]
	currentSeed = systemSeed
	for child in $system.get_children():
		child.queue_free()
		$system.remove_child(child)
	currentStar = ["M-type","K-type","G-type","B-type"][randi()%4]
	currentStarName = starName
	currentStarData = starData[currentStar]
	var amountOfPlanets = randi() % 20 + 1
	for _i in range(amountOfPlanets):
		create_planet()

func create_planet(orbitBody = $stars, maxSize = sizeTypes.max_size, orbitingSize = 0) -> void:
	#randomize()
	var planet = PLANET.instantiate()
	planet.id = get_system_bodies().size()
	
	#Determines planet type
	var planetType
	var planets = []
	for planetDat in planetData:
		if (planetData[planetDat]["size"] < maxSize or (maxSize == 0 and planetData[planetDat]["size"] == 0)) and !["terra","snow","snow_terra","frigid","exotic","ocean","grassland","scorched"].has(planetData[planetDat]["type"]):
			planets.append(planetData[planetDat])
	planets.shuffle()
	planetType = planets[0]
	planet.type = planetType
	if planet.type["type"] != "asteroids":
		planet.hasAtmosphere = bool(randi() % 2)
	else:
		planet.hasAtmosphere = false
	#Gets orbit data
	if orbitBody == $stars:
		var i = 0
		while true:
			i += 1
			planet.orbitalDistance = int(randf_range(currentStarData["min_distance"],currentStarData["max_distance"]))
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
		planet.modulate = Color.RED
	planet.orbitingBody = orbitBody
	planet.orbitalSpeed = int(randf_range(6,12))
	planet.rotationSpeed = int(randf_range(1,8))
	planet.currentOrbit = deg_to_rad(randi() % 360)
	planet.currentRot = deg_to_rad(randi() % 360)
	
	#Checks if habitable
	var size = "" if planetType["size"] > sizeTypes.small else "small_"
	if currentStarData["habital"].has(abs(planet.orbitalDistance-orbitBody.orbitalDistance)) and randi()%2 == 1:
		var type = "earth"
		match randi() % 3:
			1:
				type = "exotic"
			2:
				type = "ocean"
		planet.type = planetData[size + type]
		planet.hasAtmosphere = true
	elif !currentStarData["habital"].is_empty() and abs(planet.orbitalDistance-orbitBody.orbitalDistance) < currentStarData["habital"][currentStarData["habital"].size()-1]:
		match randi() % 6:
			0:
				planet.type = planetData[size + "grassland"]
				planet.hasAtmosphere = true
			1:
				planet.type = planetData[size + "scorched"]
				planet.hasAtmosphere = true
	elif !currentStarData["habital"].is_empty() and abs(planet.orbitalDistance-orbitBody.orbitalDistance) > currentStarData["habital"][currentStarData["habital"].size()-1]:
		if randi() % 3 ==1:
			planet.type = planetData[size + "snow"]
			planet.hasAtmosphere = true
		elif randi() % 4 ==1:
			planet.type = planetData[size + "snow_terra"]
			planet.hasAtmosphere = true
		elif randi() % 4 == 1:
			planet.type = planetData[size + "frigid"]
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
	if !get_orbiting_bodies(orbitingBody).is_empty():
		for planet in get_orbiting_bodies(orbitingBody):
			if planet != planetSelf:
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

func get_system_data() -> Dictionary:
	var data = {"system_name":currentStarName,"system_id":Global.currentSystemId,"star_type":currentStar,"system_seed":currentSeed,"planets":{},"visited_planets":visitedPlanets}
	var planets = get_system_bodies()
	for planet in planets:
		data["planets"][planet.id] = {"orbiting_body":-1 if planet.orbitingBody == $stars else planet.orbitingBody.id,"planet_type":planet.type["type"],"planet_size":planet.type["size"],"has_atmosphere":planet.hasAtmosphere,"planet_name":planet.pName,"planet_desc":planet.pDesc,"rotation_speed":planet.rotationSpeed,"orbit_speed":planet.orbitalSpeed,"orbit_distance":planet.orbitalDistance,"current_orbit":planet.currentOrbit,"current_rot":planet.currentRot}
	return data

func get_current_world_size() -> Vector2:
	return sizeData[find_planet_id(Global.currentPlanet,true).type["size"]]["world_size"]

func look_up_planet_data(type,size):
	for planetDat in planetData:
		if planetData[planetDat]["type"] == type and planetData[planetDat]["size"] == size:
			return planetDat
	return ""
