extends Node2D

var entities = {
	"slorg":preload("res://assets/enemies/Slorg.tscn"),
	"item":preload("res://assets/entities/Item.tscn"),
	"blues":preload("res://assets/entities/Blues.tscn"),
	"space_squid":preload("res://assets/enemies/Space_squid.tscn"),
	"rockius":preload("res://assets/enemies/Rockius.tscn")
	}

var loaded = false

onready var world = get_node("../World")
onready var player = get_node("../Player")

func get_entity_data():
	var data = []
	for entity in $Hold.get_children():
		data.append({"pos":entity.position,"type":entity.type,"health":entity.health,"data":entity.data})
	return data

func load_entities(data : Array):
	for entity in data:
		var newE = entities[entity["type"]].instance()
		newE.position = entity["pos"]
		newE.health = entity["health"]
		newE.data = entity["data"]
		newE.new = false
		$Hold.add_child(newE)

func find_entity(entity : String) -> String:
	for ent in entities:
		if ent.to_lower() == entity:
			return ent
	return ""

func summon_entity(entity : String, pos = player.position):
	var newE = entities[entity].instance()
	newE.position = pos
	newE.new = true
	$Hold.add_child(newE)

func spawn_item(item : Dictionary, thrown = false, pos = $"../Player".position):
	var newI = entities["item"].instance()
	newI.position = pos
	newI.data = item
	if thrown:
		newI.canPickup = false
		newI.motion = Vector2(10*rand_range(-1,1),-5)
	$Hold.add_child(newI)

func spawn_blues(amount : int, thrown = false, pos = $"../Player".position):
	var newB = entities["blues"].instance()
	newB.position = pos
	newB.data = {"amount":amount}
	if thrown:
		newB.canPickup = false
		newB.motion = Vector2(10*rand_range(-1,1),-5)
	$Hold.add_child(newB)

func _on_Spawn_timeout():
	if loaded:
		var hostileCount = 0
		var maxH = int(5*(world.worldSize.x/128)) if world.worldRules["enemy_spawning"]["value"] else 0
		var maxE = int(5*(world.worldSize.x/128)) if world.worldRules["entity_spawning"]["value"] else 0
		for entity in $Hold.get_children():
			if entity.hostile:
				hostileCount += 1
		print("SPAWNING")
		for _i in range(int(rand_range(10,50))):
			var pos = Vector2(randi()%int(world.worldSize.x),randi()%int(world.worldSize.y))
			var hostileSpawns = StarSystem.hostileSpawn[StarSystem.find_planet_id(Global.currentPlanet).type["type"]]
			if !hostileSpawns.empty() and hostileCount < maxH and world.get_block_id(pos,1) == 0 and world.get_block_id(pos,0) == 0 and world.get_block_id(pos + Vector2(0,1),1) != 0 and pos.distance_to(player.position) > 48:
				var enemy = hostileSpawns[randi() %hostileSpawns.size()]
				print("Spawning: ",enemy)
				var slorg = entities[enemy].instance()
				slorg.position = pos * Vector2(8,8)
				$Hold.add_child(slorg)
				hostileCount += 1

func _on_World_world_loaded():
	if StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere or StarSystem.find_planet_id(Global.currentPlanet).type["type"] == "asteroids":
		print("Start spawning")
		$Spawn.start()
	seed(int(Global.currentSystemId) + Global.currentPlanet)
	loaded = true
