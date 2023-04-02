extends Node2D

var entities = {"Slorg":preload("res://assets/enemies/Slorg.tscn")}

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

func _on_Spawn_timeout():
	if loaded:
		var hostileCount = 0
		var maxH = int(5*(world.worldSize.x/128))
		for entity in $Hold.get_children():
			if entity.hostile:
				hostileCount += 1
		for _i in range(int(rand_range(10,50))):
			var pos = Vector2(randi()%int(world.worldSize.x),randi()%int(world.worldSize.y))
			if hostileCount < maxH and world.get_block_id(pos,1) == 0 and world.get_block_id(pos,0) == 0 and world.get_block_id(pos + Vector2(0,1),1) != 0 and pos.distance_to(player.position) > 48:
				print("spawned at " + str(pos))
				var slorg = entities["Slorg"].instance()
				slorg.position = pos * Vector2(8,8)
				$Hold.add_child(slorg)
				hostileCount += 1

func _on_World_world_loaded():
	seed(StarSystem.currentSeed + Global.currentPlanet)
	loaded = true
