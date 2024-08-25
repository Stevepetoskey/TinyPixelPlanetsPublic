extends Node2D

var entities = {
	"slorg":preload("res://assets/enemies/Slorg.tscn"),
	"item":preload("res://assets/entities/Item.tscn"),
	"blues":preload("res://assets/entities/Blues.tscn"),
	"space_squid":preload("res://assets/enemies/Space_squid.tscn"),
	"rockius":preload("res://assets/enemies/Rockius.tscn"),
	"magma_spit":preload("res://assets/entities/magma_spit.tscn"),
	"scorched_guard":preload("res://assets/enemies/ScorchedGuard.tscn"),
	"fridged_spike":preload("res://assets/enemies/FridgedSpike.tscn"),
	"fridged_spit":preload("res://assets/entities/fridged_spit.tscn"),
	"mini_transporter":preload("res://assets/enemies/Transporter.tscn"),
	"trinanium_charge":preload("res://assets/entities/trinanium_charge.tscn"),
	"gold_spike":preload("res://assets/entities/gold_spike.tscn"),
	}

var loot = {
	"slorg":[],
	"item":[],
	"blues":[],
	"space_squid":[],
	"rockius":[],
	"magma_spit":[],
	"scorched_guard":[{"id":191,"amount":[0,1]}],
	"fridged_spike":[{"id":205,"amount":[0,1]}],
	"fridged_spit":[],
	"mini_transporter":[],
	"trinanium_charge":[],
	"gold_spike":[]
}

var loaded = false

@onready var world = get_node("../World")
@onready var player = get_node("../Player")

func get_entity_data():
	var data = []
	for entity in $Hold.get_children():
		print(entity.type)
		data.append({"pos":entity.position,"type":entity.type,"health":entity.health,"data":entity.data})
	return data

func load_entities(data : Array):
	for entity in data:
		var newE = entities[entity["type"]].instantiate()
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
	var newE = entities[entity].instantiate()
	newE.position = pos
	newE.new = true
	newE.loot = loot[entity]
	$Hold.add_child(newE)

func spawn_item(item : Dictionary, thrown = false, pos = $"../Player".position):
	var newI = entities["item"].instantiate()
	newI.position = pos
	newI.data = item
	if thrown:
		newI.canPickup = false
		newI.motion = Vector2(10*randf_range(-1,1),-5)
	$Hold.add_child(newI)

func spawn_spit(pos : Vector2, direction : float, distance : float) -> void:
	var newS = entities["magma_spit"].instantiate()
	newS.position = pos
	newS.direction = direction
	newS.distance = distance
	newS.new = true
	$Hold.add_child(newS)

func spawn_linear_spit(pos : Vector2, direction : float, type : String) -> void:
	var newS = entities[type].instantiate()
	newS.position = pos
	newS.direction = direction
	newS.new = true
	$Hold.add_child(newS)

func spawn_blues(amount : int, thrown = false, pos = $"../Player".position):
	var newB = entities["blues"].instantiate()
	newB.position = pos
	newB.data = {"amount":amount}
	if thrown:
		newB.canPickup = false
		newB.motion = Vector2(10*randf_range(-1,1),-5)
	$Hold.add_child(newB)

func _on_Spawn_timeout():
	if loaded:
		var hostileCount = 0
		var maxH = int(5*(world.worldSize.x/128)) if world.worldRules["enemy_spawning"]["value"] else 0
		var maxE = int(5*(world.worldSize.x/128)) if world.worldRules["entity_spawning"]["value"] else 0
		for entity in $Hold.get_children():
			if entity.hostile:
				hostileCount += 1
		for _i in range(int(randf_range(10,50))):
			var pos = Vector2(randi()%int(world.worldSize.x),randi()%int(world.worldSize.y))
			var hostileSpawns = StarSystem.hostileSpawn[StarSystem.find_planet_id(Global.currentPlanet).type["type"]]
			if !hostileSpawns.is_empty() and hostileCount < maxH and world.get_block_id(pos,1) == 0 and world.get_block_id(pos,0) == 0 and world.get_block_id(pos + Vector2(0,1),1) != 0 and pos.distance_to(player.position) > 48:
				var enemy = hostileSpawns[randi() %hostileSpawns.size()]
				print("Spawning: ",enemy)
				var slorg = entities[enemy].instantiate()
				slorg.position = pos * Vector2(8,8)
				$Hold.add_child(slorg)
				hostileCount += 1

func _on_World_world_loaded():
	if StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere or StarSystem.find_planet_id(Global.currentPlanet).type["type"] == "asteroids":
		print("Start spawning")
		$Spawn.start()
	seed(int(Global.currentSystemId) + Global.currentPlanet)
	loaded = true
