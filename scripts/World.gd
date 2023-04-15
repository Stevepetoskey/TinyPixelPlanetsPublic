extends Node2D

const BLOCK = preload("res://assets/Block.tscn")
const BLOCK_SIZE = Vector2(8,8)

export var worldSize = Vector2(16,24)
export var worldNoise : OpenSimplexNoise
export var noiseScale = 15
export var worldHeight = 10

onready var inventory = get_node("../CanvasLayer/Inventory")
onready var enviroment = get_node("../CanvasLayer/Enviroment")
onready var armor = get_node("../CanvasLayer/Inventory/Armor")
onready var player = get_node("../Player")
onready var entities = get_node("../Entities")

var currentPlanet : Object

var worldLoaded = false

var interactableBlocks = [12,16,28]

var transparentBlocks = [0,1,6,7,9,11,12,20,24,10,28,30]
var blockData = {
	1:{"texture":preload("res://textures/blocks2X/grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":1,"amount":1}]},
	2:{"texture":preload("res://textures/blocks2X/dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}]},
	3:{"texture":preload("res://textures/blocks2X/stone.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}]},
	6:{"texture":preload("res://textures/blocks2X/flower1.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[]},
	7:{"texture":preload("res://textures/blocks2X/flower2.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[]},
	8:{"texture":preload("res://textures/blocks2X/Cobble.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}]},
	9:{"texture":preload("res://textures/blocks/tree_small.png"),"hardness":7,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":[3,6]},{"id":11,"amount":[0,3]}]},
	10:{"texture":preload("res://textures/blocks2X/log_front.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":1}]},
	11:{"texture":preload("res://textures/items/pinecone.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":11,"amount":1}]},
	12:{"texture":preload("res://textures/blocks2X/crafting_table.png"),"hardness":2,"breakWith":"Axe","canHaverst":1,"drops":[{"id":12,"amount":1}]},
	13:{"texture":preload("res://textures/blocks2X/planks.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":13,"amount":1}]},
	14:{"texture":preload("res://textures/blocks2X/sand.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":14,"amount":1}]},
	15:{"texture":preload("res://textures/blocks2X/stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":15,"amount":1}]},
	16:{"texture":preload("res://textures/blocks2X/oven.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":16,"amount":1}]},
	17:{"texture":preload("res://textures/blocks2X/mud_stone.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":17,"amount":1}]},
	18:{"texture":preload("res://textures/blocks2X/mud_stone_dust.png"),"hardness":0.5,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":18,"amount":1}]},
	19:{"texture":preload("res://textures/blocks2X/mud_stone_bricks.png"),"hardness":1.4,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":19,"amount":1}]},
	20:{"texture":preload("res://textures/blocks2X/glass_icon.png"),"hardness":0.1,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":20,"amount":1}]},
	21:{"texture":preload("res://textures/blocks2X/snow_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":21,"amount":1}]},
	22:{"texture":preload("res://textures/blocks2X/sandstone.png"),"hardness":1.3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":22,"amount":1}]},
	23:{"texture":preload("res://textures/blocks2X/sandstone_bricks.png"),"hardness":2.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":23,"amount":1}]},
	24:{"texture":preload("res://textures/blocks2X/grass_snow.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":24,"amount":1}]},
	25:{"texture":preload("res://textures/blocks2X/clay.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":25,"amount":1}]},
	26:{"texture":preload("res://textures/blocks2X/bricks.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":26,"amount":1}]},
	27:{"texture":preload("res://textures/blocks2X/brick_shingles.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":27,"amount":1}]},
	28:{"texture":preload("res://textures/blocks2X/smithing_table.png"),"hardness":2.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":28,"amount":1}]},
	29:{"texture":preload("res://textures/blocks2X/copper_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":29,"amount":1}]},
	30:{"texture":preload("res://textures/blocks2X/platform_full.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":30,"amount":1}]},
	55:{"texture":preload("res://textures/blocks2X/silver_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":55,"amount":1}]},
}

var itemData = {
	4:{"texture_loc":preload("res://textures/items/wood_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":1,"speed":1},
	5:{"texture_loc":preload("res://textures/items/stick.png"),"type":"Item"},
	31:{"texture_loc":preload("res://textures/items/stone_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":2,"speed":2},
	32:{"texture_loc":preload("res://textures/items/armor/shirt.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false}},
	33:{"texture_loc":preload("res://textures/items/armor/jeans.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"air_tight":false}},
	34:{"texture_loc":preload("res://textures/items/armor/black_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"air_tight":false}},
	35:{"texture_loc":preload("res://textures/items/armor/copper_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":1,"speed":0,"air_tight":false}},
	36:{"texture_loc":preload("res://textures/items/armor/copper_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":3,"speed":-1,"air_tight":false}},
	37:{"texture_loc":preload("res://textures/items/armor/copper_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":2,"speed":-1,"air_tight":false}},
	38:{"texture_loc":preload("res://textures/items/armor/copper_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":1,"speed":0,"air_tight":false}},
	39:{"texture_loc":preload("res://textures/items/armor/silver_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":2,"speed":0,"air_tight":false}},
	40:{"texture_loc":preload("res://textures/items/armor/silver_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":5,"speed":-2,"air_tight":false}},
	41:{"texture_loc":preload("res://textures/items/armor/silver_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":3,"speed":-1,"air_tight":false}},
	42:{"texture_loc":preload("res://textures/items/armor/silver_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":2,"speed":0,"air_tight":false}},
	43:{"texture_loc":preload("res://textures/items/armor/tuxedo.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false}},
	44:{"texture_loc":preload("res://textures/items/armor/slacks.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"air_tight":false}},
	45:{"texture_loc":preload("res://textures/items/armor/top_hat.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"air_tight":false}},
	46:{"texture_loc":preload("res://textures/items/armor/space_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"air_tight":true}},
	47:{"texture_loc":preload("res://textures/items/armor/space_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":1,"speed":-2,"air_tight":true}},
	48:{"texture_loc":preload("res://textures/items/armor/space_pants.png"),"type":"armor","armor_data":{"armor_type":"pants","def":1,"speed":-1,"air_tight":true}},
	49:{"texture_loc":preload("res://textures/items/armor/space_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"air_tight":true}},
	50:{"texture_loc":preload("res://textures/items/armor/red_dress.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false}},
	51:{"texture_loc":preload("res://textures/items/armor/red_dress_bottom.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":-1,"air_tight":false}},
	52:{"texture_loc":preload("res://textures/items/copper.png"),"type":"Item"},
	53:{"texture_loc":preload("res://textures/items/copper_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":3,"speed":4},
	54:{"texture_loc":preload("res://textures/items/stone_spear.png"),"type":"weapon","weapon_type":"Spear","dmg":2,"speed":0.1},
	56:{"texture_loc":preload("res://textures/items/silver.png"),"type":"Item"},
	57:{"texture_loc":preload("res://textures/items/silver_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":4,"speed":6},
}

signal update_blocks
signal world_loaded

func _ready():
	StarSystem.connect("planet_ready",self,"start_world")
	Global.connect("loaded_data",self,"start_world")
	if Global.gameStart:
		if Global.new:
			StarSystem.start_game()
		else:
			start_world()

#func _process(delta):
#	print(Engine.get_frames_per_second())

func start_world():
	print("World started")
	
	#world size stuff
	worldSize = StarSystem.get_current_world_size()
	get_node("../Player/Camera2D").limit_right = worldSize.x * BLOCK_SIZE.x - 4
	get_node("../Player/Camera2D").limit_bottom = (worldSize.y+1) * BLOCK_SIZE.y - 4
	$StaticBody2D/Right.position.x = worldSize.x * BLOCK_SIZE.x + 2
	$StaticBody2D/Bottom.position.y = worldSize.y * BLOCK_SIZE.y + 2
	
	var worldType = StarSystem.find_planet_id(Global.currentPlanet).type["type"]
	get_node("../CanvasLayer/Black").show()
	if !StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere:
		get_node("../CanvasLayer/ParallaxBackground/SkyLayer").hide()
	if Global.new:
		#StarSystem.visitedPlanets.append(Global.currentPlanet)
		if !Global.gameStart:
			var playerData = Global.playerData
			inventory.inventory = playerData["inventory"]
			armor.armor = playerData["armor"]
			armor.emit_signal("updated_armor",armor.armor)
			if playerData.has("inventory_refs"):
				inventory.jId = playerData["inventory_refs"]["j"]
				inventory.kId = playerData["inventory_refs"]["k"]
		else:
			inventory.add_to_inventory(4,1)
			armor.armor = {"Helmet":{"id":46,"amount":1},"Hat":{},"Chestplate":{"id":47,"amount":1},"Shirt":{},"Leggings":{"id":48,"amount":1},"Pants":{},"Boots":{"id":49,"amount":1},"Shoes":{}}
			armor.emit_signal("updated_armor",armor.armor)
		generateWorld(worldType)
		#Global.save(get_world_data())
	else:
		load_world_data()#Global.load_planet(StarSystem.currentSeed,Global.currentPlanet))
	enviroment.set_background(worldType)
	emit_signal("world_loaded")
	get_node("../CanvasLayer/ParallaxBackground2/Sky").init_sky()
	worldLoaded = true
	get_node("../CanvasLayer/Black/AnimationPlayer").play("fadeOut")
	yield(get_tree(),"idle_frame")
	emit_signal("update_blocks")
	Global.gameStart = false
	inventory.update_inventory()

func generateWorld(worldType : String):
	var worldSeed = StarSystem.currentSeed + Global.currentPlanet
	seed(worldSeed)
	worldNoise.seed = worldSeed
	var copperOre = OpenSimplexNoise.new()
	copperOre.seed = StarSystem.currentSeed;copperOre.period = 2;copperOre.persistence = 0.5;copperOre.lacunarity = 2
	match worldType:
		"terra":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == height:
						set_block_all(pos,1)
						if get_block(pos - Vector2(0,2),1) == null and randi() % 5 == 1:
							set_block(pos - Vector2(0,1),1,9)
						elif get_block(pos - Vector2(0,1),1) == null:
							if randi() % 3 == 1:
								set_block(pos - Vector2(0,1),1,6)
							elif randi() % 3 == 1:
								set_block(pos - Vector2(0,1),1,7)
					elif y > height and y < height+3:
						set_block_all(pos,2)
					elif y >= height+3:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,29)
						else:
							set_block_all(pos,3)
		"stone":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,8)
					elif y >= height+3:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,29)
						else:
							set_block_all(pos,3)
		"desert":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,14)
					elif y >= height+3:
						set_block_all(pos,22)
		"mud":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+randi()%2+1:
						set_block_all(pos,18)
					elif y > height and y < height+4:
						set_block_all(pos,17)
					elif y >= height+4:
						set_block_all(pos,3)
		"snow":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,21)
					elif y >= height+3:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,55)
						else:
							set_block_all(pos,3)
		"snow_terra":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == height:
						set_block_all(pos,24)
						if get_block(pos - Vector2(0,2),1) == null and randi() % 5 == 1:
							set_block(pos - Vector2(0,1),1,9)
					elif y > height and y < height+3:
						set_block_all(pos,2)
					elif y >= height+3:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,55)
						else:
							set_block_all(pos,3)

func get_world_data() -> Dictionary:
	var data = {}
	data["player"] = {"armor":armor.armor,"inventory":inventory.inventory,"inventory_refs":{"j":inventory.jId,"k":inventory.kId},"pos":player.position,"health":player.health,"max_health":player.maxHealth,"oxygen":player.oxygen,"max_oxygen":player.maxOxygen,"current_planet":Global.currentPlanet,"current_system":StarSystem.currentSeed}
	data["system"] = StarSystem.get_system_data()
	data["planet"] = {"blocks":[],"entities":entities.get_entity_data()}
	for block in $blocks.get_children():
		data["planet"]["blocks"].append({"id":block.id,"layer":block.layer,"position":block.pos,"data":block.data})
	return data

func load_world_data() -> void:#data : Dictionary) -> void:
	#Loads player data
	var playerData = Global.load_player()
	player.health = playerData["health"]
	player.oxygen = playerData["oxygen"]
	player.maxHealth = playerData["max_health"]
	player.maxOxygen = playerData["max_oxygen"]
	inventory.inventory = playerData["inventory"]
	armor.armor = playerData["armor"]
	armor.emit_signal("updated_armor",armor.armor)
	if playerData.has("inventory_refs"):
		inventory.jId = playerData["inventory_refs"]["j"]
		inventory.kId = playerData["inventory_refs"]["k"]
		inventory.update_inventory()
	#Loads planet data
	var planetData = Global.load_planet(StarSystem.currentSeed,Global.currentPlanet)
	entities.load_entities(planetData["entities"])
	for block in planetData["blocks"]:
		set_block(block["position"],block["layer"],block["id"])

func get_item_data(item_id : int) -> Dictionary:
	if blockData.has(item_id):
		return blockData[item_id]
	elif itemData.has(item_id):
		return itemData[item_id]
	return {}

func get_item_texture(item_id : int) -> Resource:
	if blockData.has(item_id):
		return blockData[item_id]["texture"]
	elif itemData.has(item_id):
		return itemData[item_id]["texture_loc"]
	return null

func get_block(pos : Vector2, layer : int) -> Object:
	if $blocks.has_node(str(pos.x) + "," + str(pos.y) + "," + str(layer)):
		return $blocks.get_node(str(pos.x) + "," + str(pos.y) + "," + str(layer))
	return null

func get_block_id(pos : Vector2, layer : int) -> int:
	if get_block(pos,layer) != null:
		return get_block(pos,layer).id
	return 0

func set_block_all(pos: Vector2, id : int) -> void:
	set_block(pos,0,id)
	set_block(pos,1,id)

func set_block(pos : Vector2, layer : int, id : int, update = false) -> void:
	if get_block(pos,layer) != null or (id == 0 and get_block(pos,layer) != null):
		get_block(pos,layer).queue_free()
		yield(get_tree(),"idle_frame")
	if id > 0:
		var block = BLOCK.instance()
		block.position = pos * BLOCK_SIZE
		block.id = id
		block.layer = layer
		block.name = str(pos.x) + "," + str(pos.y) + "," + str(layer)
		block.get_node("Sprite").texture = get_item_texture(id)
		$blocks.add_child(block)
	if update:
		for x in range(pos.x-1,pos.x+2):
			for y in range(pos.y-1,pos.y+2):
				if Vector2(x,y) != pos and get_block(Vector2(x,y),1) != null:
					get_block(Vector2(x,y),1).on_update()
				if get_block(Vector2(x,y),0) != null:
					get_block(Vector2(x,y),0).on_update()
					#print(get_block_id(Vector2(x,y),layer))
		#emit_signal("update_blocks")

func build_event(action : String, pos : Vector2, layer : int,id = 0, itemAction = true) -> void:
	if action == "Build" and get_block(pos,layer) == null and blockData.has(id):
		set_block(pos,layer,id,true)
		if itemAction:
			inventory.remove_id_from_inventory(id,1)
	elif action == "Break" and get_block(pos,layer) != null:
		var block = get_block(pos,layer).id
		set_block(pos,layer,0,true)
		if itemAction:
			var itemsToDrop = blockData[block]["drops"]
			for i in range(itemsToDrop.size()):
				if typeof(itemsToDrop[i]["amount"]) != TYPE_ARRAY:
					inventory.add_to_inventory(itemsToDrop[i]["id"],itemsToDrop[i]["amount"])
				else:
					inventory.add_to_inventory(itemsToDrop[i]["id"],int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1)))

func _on_GoUp_pressed():
	Global.save(get_world_data())
	StarSystem.start_space()
