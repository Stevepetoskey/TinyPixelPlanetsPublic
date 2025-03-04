extends Node2D

const WIRE = preload("res://assets/blocks/wire.tscn")
const BLOCK_SIZE = Vector2(8,8)

@export var worldSize = Vector2(16,24)
@export var worldNoise : Noise
@export var caveNoise : Noise
@export var noiseScale : float = 15.0
@export var worldHeight = 20
@export var seaLevel : int = 50
@export var worldType : String
@export var lightFalloffHeight : int = 0

@onready var inventory = $"../CanvasLayer/Inventory"
@onready var environment = $"../CanvasLayer/Environment"
@onready var armor = $"../CanvasLayer/Inventory/Armor"
@onready var player = $"../Player"
@onready var entities = $"../Entities"
@onready var meteors = $"../CanvasLayer/Environment/Meteors"

var blockTypes = {
	"block":preload("res://assets/blocks/Block.tscn"),
	"simple":preload("res://assets/blocks/SimpleBlock.tscn"),
	"foliage":preload("res://assets/blocks/Foliage.tscn"),
	"platform":preload("res://assets/blocks/Platform.tscn"),
	"water":preload("res://assets/blocks/Water.tscn"),
	"lily_mart":preload("res://assets/shops/LilyMart.tscn"),
	"skips_stones":preload("res://assets/shops/SkipsStones.tscn"),
	"sign":preload("res://assets/blocks/Sign.tscn"),
	"lever":preload("res://assets/blocks/Lever.tscn"),
	"display_block":preload("res://assets/blocks/DisplayBlock.tscn"),
	"logic_block":preload("res://assets/blocks/LogicBlock.tscn"),
	"flip_block":preload("res://assets/blocks/FlipBlock.tscn"),
	"door":preload("res://assets/blocks/Door.tscn"),
	"ghost":preload("res://assets/blocks/GhostBlock.tscn"),
	"button":preload("res://assets/blocks/Button.tscn"),
	"spawner":preload("res://assets/blocks/Spawner.tscn"),
	"music_player":preload("res://assets/blocks/MusicPlayer.tscn"),
	"spike":preload("res://assets/blocks/Spike.tscn"),
	"timer_block":preload("res://assets/blocks/TimerBlock.tscn"),
	"locator":preload("res://assets/blocks/Locator.tscn")
}

var currentPlanet : Object

var worldLoaded = false
var hasGravity = true

var waterUpdateList = []

var lightMap : Image
var lightIntensityMap : Image

var worldRules = {
	"break_blocks":{"value":true,"type":"bool"},
	"place_blocks":{"value":true,"type":"bool"},
	"interact_with_blocks":{"value":true,"type":"bool"},
	"entity_spawning":{"value":true,"type":"bool"},
	"enemy_spawning":{"value":true,"type":"bool"},
	"world_spawn_x":{"value":-1,"type":"int"},
	"world_spawn_y":{"value":-1,"type":"int"}
}

var generationData = {
	"terra":{
		"noise":preload("res://noise/Terra.tres"),
		"noise_scale":20,
		"world_height":20,
		"water_level":47
	},
	"stone":{
		"noise":preload("res://noise/Stone.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"desert":{
		"noise":preload("res://noise/Desert.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"mud":{
		"noise":preload("res://noise/Mud.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"snow":{
		"noise":preload("res://noise/Desert.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"snow_terra":{
		"noise":preload("res://noise/Terra.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"exotic":{
		"noise":preload("res://noise/Terra.tres"),
		"noise_scale":20,
		"world_height":20
	},
	"asteroids":{
		"noise":preload("res://noise/Asteroids.tres"),
		"noise_scale":0.3,
		"world_height":20
	},
	"ocean":{
		"noise":preload("res://noise/Ocean.tres"),
		"noise_scale":30,
		"world_height":22,
		"water_level":37
	},
	"grassland":{
		"noise":preload("res://noise/Grassland.tres"),
		"noise_scale":13,
		"world_height":18,
		"water_level":50
	},
	"scorched":{
		"noise":preload("res://noise/Scorched.tres"),
		"noise_scale":25,
		"world_height":20,
	},
	"frigid":{
		"noise":preload("res://noise/Terra.tres"),
		"noise_scale":25,
		"world_height":20,
	},
	"mystical":{
		"noise":preload("res://noise/Terra.tres"),
		"noise_scale":20,
		"world_height":20,
		"water_level":47
	}
}

var lootTables = { #{id:Block/Item id, amount:max amount, rarity: item chance, group: what group it is in to prevent more than one from a group
	"scorched":[
		{"id":165,"amount":5,"rarity":3,"group":"none"},
		{"id":74,"amount":3,"rarity":6,"group":"none"},
		{"id":43,"amount":1,"rarity":3,"group":"clothes"},
		{"id":44,"amount":1,"rarity":3,"group":"clothes"},
		{"id":45,"amount":1,"rarity":3,"group":"clothes"},
		{"id":215,"amount":1,"rarity":2,"group":"none"},
		{"id":238,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":239,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":240,"amount":1,"rarity":6,"group":"music_chip"}
	],
	"mines":[
		{"id":193,"amount":3,"rarity":6,"group":"none"},
		{"id":52,"amount":6,"rarity":3,"group":"none"},
		{"id":23,"amount":24,"rarity":2,"group":"none"},
		{"id":196,"amount":5,"rarity":3,"group":"none"},
		{"id":35,"amount":1,"rarity":3,"group":"clothes"},
		{"id":36,"amount":1,"rarity":3,"group":"clothes"},
		{"id":37,"amount":1,"rarity":3,"group":"clothes"},
		{"id":38,"amount":1,"rarity":3,"group":"clothes"},
		{"id":238,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":239,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":240,"amount":1,"rarity":6,"group":"music_chip"}
	],
	"fridged":[
		{"id":56,"amount":5,"rarity":3,"group":"none"},
		{"id":215,"amount":1,"rarity":2,"group":"none"},
		{"id":238,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":239,"amount":1,"rarity":6,"group":"music_chip"},
		{"id":240,"amount":1,"rarity":6,"group":"music_chip"}
	],
	"fridged_boss":[
		{"id":56,"amount":10,"rarity":3,"group":"none"},
		{"id":215,"amount":2,"rarity":1,"group":"none"},
		{"id":238,"amount":1,"rarity":3,"group":"music_chip"},
		{"id":239,"amount":1,"rarity":3,"group":"music_chip"},
		{"id":240,"amount":1,"rarity":3,"group":"music_chip"}
	]
}

var upgrades : Dictionary = { #upgrade:{
	"jetpack":{"name":"Jetpack","apply_to":"shirt"},
	#"wallclimb":{"name":"Wall climb","apply_to":"shoes"},
	"movement_speed":{"name":"Movement+","apply_to":"pants"},
	"oxygen":{"name":"Oxygen+","apply_to":"helmet"},
	"protection":{"name":"Protection","apply_to":"armor"},
	"speed":{"name":"Speed+","apply_to":"tool"},
	#"auto_smelt":{"name":"Auto smelt","apply_to":"tool"},
	"damage":{"name":"Damage+","apply_to":"weapon"},
	"poison":{"name":"Poison","apply_to":"weapon"},
}

var fullGrownItemDrops = {
	121:[{"id":121,"amount":[0,3]},{"id":125,"amount":[1,2]}],
	122:[{"id":122,"amount":[0,3]},{"id":126,"amount":[1,2]}],
	123:[{"id":123,"amount":[0,3]},{"id":127,"amount":[1,2]}],
	221:[{"id":221,"amount":[2,4]}]
}

signal update_blocks
signal world_loaded
signal blocks_changed

func _ready():
	#Init block and item data dictionaries
	var tempBlockData : Dictionary = Global.load_json_data("res://data/json_data/block_data.json")
	for key : String in tempBlockData:
		GlobalData.blockData[int(key)] = tempBlockData[key]
	var tempItemData : Dictionary = Global.load_json_data("res://data/json_data/item_data.json")
	for key : String in tempItemData:
		GlobalData.itemData[int(key)] = tempItemData[key]
	#Starts world
	var _er = StarSystem.connect("planet_ready", start_world)
	_er = Global.connect("loaded_data", start_world)
	get_tree().paused = false
	if Global.gameStart:
		StarSystem.start_game()

func start_world():
	print("World started")
	#Waits for planet data to be ready
	if !StarSystem.planetReady:
		await StarSystem.planet_ready
	worldSize = StarSystem.get_current_world_size()
	var currentPlanetData = StarSystem.find_planet_id(Global.currentPlanet)
	worldType = currentPlanetData.type["type"]
	#Inits light renderer
	lightFalloffHeight = worldSize.y
	$"../LightRenderViewport/LightRender".get_node("LightingViewport/SubViewport/LightRect").material.set_shader_parameter("world_size",worldSize)
	lightMap = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGBA8)
	lightIntensityMap = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGBA8)
	lightMap.fill(Color.WHITE)
	lightIntensityMap.fill(Color("FF000005"))
	lightIntensityMap.fill_rect(Rect2(Vector2(0,lightFalloffHeight),Vector2(worldSize.x,worldSize.y-lightFalloffHeight)),Color("00000000"))
	lightMap.fill_rect(Rect2(Vector2(0,lightFalloffHeight),Vector2(worldSize.x,worldSize.y-lightFalloffHeight)),Color("00000000"))
	#Inits world borders and camera borders
	$StaticBody2D/Right.position = Vector2(worldSize.x * BLOCK_SIZE.x + 2,(worldSize.y * BLOCK_SIZE.y) / 2)
	$StaticBody2D/Right.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$"../Player/PlayerCamera".limit_right = worldSize.x * BLOCK_SIZE.x -4
	$"../Player/PlayerCamera".limit_bottom = worldSize.y * BLOCK_SIZE.y + 24
	$StaticBody2D/Left.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$StaticBody2D/Left.position.y = (worldSize.y * BLOCK_SIZE.y) / 2 - 8
	$StaticBody2D/Bottom.shape.extents.y = (worldSize.x * BLOCK_SIZE.x) / 2
	$StaticBody2D/Bottom.position = Vector2((worldSize.x * BLOCK_SIZE.x) / 2,worldSize.y * BLOCK_SIZE.y)
	#Hides atmosphere layer if planet does not have atmosphere
	if !currentPlanetData.hasAtmosphere:
		$"../CanvasLayer/ParallaxBackground/SkyLayer".hide()
	if worldType == "asteroids":
		hasGravity = false
	if !Global.gameStart: #erases pos if landing on a planet
		Global.playerData.erase("pos")
	if !(Global.newPlanet and Global.gameStart): #Loads player data if not new
		print("LOADING PLAYER DATA")
		load_player_data()
	if Global.newPlanet or Global.load_planet(Global.currentSystemId,Global.currentPlanet).is_empty(): #Generates if is new planet
		if Global.gameStart: #This is if the game is a new save
			player.health = Global.gamerules["starting_hp"]
			player.maxHealth = Global.gamerules["max_hp"]
			player.get_node("Textures/body").modulate = Global.playerBase["skin"]
			player.gender = Global.playerBase["sex"]
			inventory.add_to_inventory(4,1)
			armor.armor = {"Helmet":{"id":46,"amount":1,"data":{}},"Hat":{},"Chestplate":{"id":47,"amount":1,"data":{}},"Shirt":{},"Leggings":{"id":48,"amount":1,"data":{}},"Pants":{},"Boots":{"id":49,"amount":1,"data":{}},"Shoes":{}}
			armor.emit_signal("updated_armor",armor.armor)
		#Generates like normal, unless specified to generate a custom world
		print("generating World")
		generateWorld(worldType if Global.gamerules["custom_generation"] == "" else Global.gamerules["custom_generation"])
	else:
		print("loading world")
		load_world_data()
	environment.set_background(worldType)
	world_loaded.emit()
	$"../CanvasLayer/ParallaxBackground2/Sky".init_sky()
	worldLoaded = true
	$"../CanvasLayer/Black/AnimationPlayer".play("fadeOut")
	await get_tree().process_frame
	update_light_texture()
	update_blocks.emit()
	Global.gameStart = false
	inventory.update_inventory()
	Global.save("planet",get_world_data())
	Global.gameStart = false

func generateWorld(worldType : String):
	var worldSeed = int(Global.currentSystemId) + Global.currentPlanet
	var currentPlanetData = StarSystem.find_planet_id(Global.currentPlanet)
	seed(worldSeed)
	worldNoise = generationData[worldType]["noise"]
	worldNoise.seed = worldSeed
	caveNoise.seed = worldSeed
	noiseScale = generationData[worldType]["noise_scale"]
	worldHeight = generationData[worldType]["world_height"]
	print(worldHeight)
	if generationData[worldType].has("water_level"):
		seaLevel = generationData[worldType]["water_level"]
	match worldType:
		"terra":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= seaLevel and y < height:
						set_block(pos,1,117,false,{"water_level":4})
					elif y == height:
						if y <= seaLevel:
							set_block_all(pos,1)
							if get_block(pos - Vector2(0,2),1) == null and randi() % 5 == 1:
								set_block(pos - Vector2(0,1),1,9)
							elif get_block(pos - Vector2(0,1),1) == null:
								if randi() % 3 == 1:
									set_block(pos - Vector2(0,1),1,6)
								elif randi() % 3 == 1:
									set_block(pos - Vector2(0,1),1,7)
								elif randi() % 6 == 1:
									set_block(pos - Vector2(0,1),1,128)
						else:
							set_block_all(pos,2)
					elif y > height and y < height+3:
						set_block_all(pos,2)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 32 and randi_range(0,50) == 1: #copper ore
						var pos = Vector2(x,y)
						for i in range(randi_range(3,6)):
							if get_block_id(pos,1) == 3:
								set_block_all(pos,29)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"stone":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,8)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 0 and randi_range(0,25) == 1: #copper ore
						var pos = Vector2(x,y)
						for i in range(randi_range(3,6)):
							if get_block_id(pos,1) == 3:
								set_block_all(pos,29)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"desert":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,14)
						if y == height and currentPlanetData.hasAtmosphere and get_block_id(pos - Vector2(0,1),1) == 0 and randi_range(0,10) == 1:
							set_block(pos-Vector2(0,1),1,196,false)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,22)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 0 and randi_range(0,300) == 1: #gold ore
						var pos = Vector2(x,y)
						for i in range(randi_range(2,4)):
							if get_block_id(pos,1) == 22:
								set_block(pos,randi_range(0,1),192,false)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
			if StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere and randi_range(0,1) == 0:
				#mines
				generate_dungeon("mines","mines_shaft",randi_range(15,30),[13],true)
		"mud":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if caveNoise.get_noise_3d(x,y,2) + min(0,(y-height-6)/4.0) < 0.35:
						if caveNoise.get_noise_3d(x,y,2) + min(0,(y-height-6)/4.0) < 0.25:
							if y >= height and y < height+randi()%2+1:
								set_block_all(pos,18)
							elif y > height and y < height+4:
								set_block_all(pos,17)
							elif y >= height+4 and y < worldSize.y-1:
								set_block_all(pos,3)
						else:
							if get_block_id(pos - Vector2(0,1),1) == 0 and randi_range(0,2) <2:
								set_block(pos,1,219)
								if randi_range(0,1) == 1:
									set_block(pos - Vector2(0,1),1,218)
							else:
								set_block_all(pos,17)
					elif y > height and randi_range(0,1) == 1:
						set_block(pos,1,217)
					if caveNoise.get_noise_3d(x,y,-5) + min(0,(y-height-6)/4.0) < 0.35:
						if caveNoise.get_noise_3d(x,y,2) + min(0,(y-height-6)/4.0) < 0.25:
							if y >= height and y < height+randi()%2+1:
								set_block(pos,0,18)
							elif y > height and y < height+4:
								set_block(pos,0,17)
							elif y >= height+4 and y < worldSize.y-1:
								set_block(pos,0,3)
						else:
							set_block(pos,0,17)
					elif y > height and randi_range(0,1) == 1:
						set_block(pos,0,217)
					if y == worldSize.y-1:
						set_block_all(pos,144)
		"snow":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,21)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 32 and randi_range(0,100) == 1: #silver ore
						var pos = Vector2(x,y)
						for i in range(randi_range(3,6)):
							if get_block_id(pos,1) == 3:
								set_block_all(pos,55)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"snow_terra":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == height:
						set_block_all(pos,24)
						if get_block(pos - Vector2(0,2),1) == null:
							if randi() % 5 == 1:
								set_block(pos - Vector2(0,1),1,9)
							elif randi() % 7 == 1:
								set_block(pos - Vector2(0,1),1,220)
					elif y > height and y < height+3:
						set_block_all(pos,2)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 32 and randi_range(0,100) == 1: #silver ore
						var pos = Vector2(x,y)
						for i in range(randi_range(3,6)):
							if get_block_id(pos,1) == 3:
								set_block_all(pos,55)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"exotic":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == height:
						set_block_all(pos,69)
						if get_block(pos - Vector2(0,2),1) == null and randi() % 5 == 1:
							set_block(pos - Vector2(0,1),1,76)
					elif y > height and y < height+3:
						set_block_all(pos,70)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,71)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 32 and randi_range(0,100) == 1: #Rhodonite ore
						var pos = Vector2(x,y)
						for i in range(randi_range(2,4)):
							if get_block_id(pos,1) == 71:
								set_block_all(pos,73)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"asteroids":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if worldNoise.get_noise_2d(x,y) > noiseScale:
						var pos = Vector2(x,y)
						set_block_all(pos,112)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var pos : Vector2 = Vector2(x,y)
					var ore : int = 0 if randi_range(0,50) != 1 else [104,105,106,107].pick_random()
					if ore != 0:
						for i in range(randi_range(3,6)):
							if get_block_id(pos,1) == 112:
								set_block_all(pos,ore)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"ocean":
			for x in range(worldSize.x):
				var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
				for y in range(worldSize.y):
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == worldSize.y-1:
						set_block_all(pos,144)
					elif y >= height:
						set_block_all(pos,118)
					elif y > seaLevel:
						set_block(pos,1,117,false,{"water_level":4})
		"grassland":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= seaLevel and y < height:
						set_block(pos,1,117,false,{"water_level":4})
					elif y == height:
						if y <= seaLevel:
							set_block_all(pos,146)
							if get_block(pos - Vector2(0,2),1) == null and randi() % 20 == 1:
								set_block(pos - Vector2(0,1),1,155)
							elif get_block(pos - Vector2(0,1),1) == null:
								if randi() % 3 == 1:
									set_block(pos - Vector2(0,1),1,160)
								elif randi() % 3 == 1:
									set_block(pos - Vector2(0,1),1,161)
						else:
							set_block_all(pos,147)
					elif y > height and y < height+3:
						set_block_all(pos,147)
					elif y >= height+3 and y < worldSize.y-1:
						if worldNoise.get_noise_2d(x,y) > 0.20:
							set_block_all(pos,149)
						elif worldNoise.get_noise_2d(x,y) < -0.20:
							set_block_all(pos,150)
						else:
							set_block_all(pos,148)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 32 and randi_range(0,50) == 1: #iron ore
						var pos = Vector2(x,y)
						for i in range(randi_range(3,6)):
							if [148,149,150].has(get_block_id(pos,1)):
								set_block_all(pos,{148:151,149:152,150:153}[get_block_id(pos,1)])
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()
		"scorched":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,178)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,177)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 0:
						if randi_range(0,50) == 1: #iron ore
							var pos = Vector2(x,y)
							for i in range(randi_range(3,6)):
								if get_block_id(pos,1) == 177:
									set_block_all(pos,179)
								if randi_range(0,1) == 1:
									pos.x += [-1,1].pick_random()
								else:
									pos.y += [-1,1].pick_random()
						elif randi_range(0,40) == 1: #Magma 
							var pos = Vector2(x,y)
							for i in range(randi_range(5,30)):
								if [178].has(get_block_id(pos,1)):
									set_block_all(pos,184)
								if randi_range(0,1) == 1:
									pos.x += [-1,1].pick_random()
								else:
									pos.y += [-1,1].pick_random()
			#Scorched dungeon
			if randi_range(1,2) == 1:
				generate_dungeon("scorched","boss_scorched",randi_range(30,50))
		"frigid":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == height:
						set_block_all(pos,199)
					elif y > height and y <= height+3:
						set_block_all(pos,198)
					elif y > height+3 and y < worldSize.y-1:
						set_block_all(pos,197)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 0:
						if randi_range(0,50) == 1: #silver ore
							var pos = Vector2(x,y)
							for i in range(randi_range(3,6)):
								if get_block_id(pos,1) == 197:
									set_block_all(pos,200)
								if randi_range(0,1) == 1:
									pos.x += [-1,1].pick_random()
								else:
									pos.y += [-1,1].pick_random()
			#frigid dungeon
			if randi_range(1,2) == 1:
				generate_dungeon("fridged","boss_fridged",randi_range(30,50))
		"mystical":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= seaLevel and y < height:
						set_block(pos,1,117,false,{"water_level":4})
					elif y == height:
						if y <= seaLevel:
							set_block_all(pos,283)
							if get_block(pos - Vector2(0,2),1) == null and randi() % 8 == 1:
								set_block(pos - Vector2(0,1),1,299)
							elif get_block(pos - Vector2(0,1),1) == null:
								if randi() % 5 == 1:
									set_block(pos - Vector2(0,1),1,294)
								elif randi() % 5 == 1:
									set_block(pos - Vector2(0,1),1,295)
								elif randi() % 5 == 1:
									set_block(pos - Vector2(0,1),1,296)
						else:
							set_block_all(pos,284)
					elif y > height and y < height+3:
						set_block_all(pos,284)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,285)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
			#Ores
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if y >= 48 and randi_range(0,200) == 1: #diamond ore
						var pos = Vector2(x,y)
						var ore = 290 if randi() % 3 != 0 else (291 if randi() % 3 != 0 else 292)
						for i in range(randi_range(1,4)):
							if get_block_id(pos,1) == 285:
								set_block(pos,randi_range(0,1),ore)
							if randi_range(0,1) == 1:
								pos.x += [-1,1].pick_random()
							else:
								pos.y += [-1,1].pick_random()

func generate_dungeon(dungeonGroup : String, startingPiece : String, dungeonSize : int, replaceFloorBlock := [], keepOnGround := false) -> void:
	var dungeonPieces = Global.load_structures(dungeonGroup)
	var dungeonBossRoom = Global.load_structure(startingPiece + ".dat")
	var pos = Vector2(randi_range(0,worldSize.x-12),0)
	var size = dungeonBossRoom["size"]
	pos.y = (worldSize.y - (int(worldNoise.get_noise_1d(pos.x) * noiseScale) + worldHeight))
	while !Rect2(Vector2(0,0),worldSize).encloses(Rect2(pos,size)):
		pos.y -= 1
		if pos.y <= 0:
			return
	var currentId = 0
	var openLinks = {0:[]}
	var dungeon = {0:{"position":pos,"size":dungeonBossRoom["size"]}}
	for link in dungeonBossRoom["structure"]["link_blocks"]:
		openLinks[currentId].append(link)
	for block in dungeonBossRoom["structure"]["blocks"]:
		if replaceFloorBlock.is_empty() or !replaceFloorBlock.has(block["id"]):
			generate_block_from_structure(block,block["position"] + pos)
	for room in range(dungeonSize):
		currentId = room + 1
		var selectedLinkRoom : int = openLinks.keys().pick_random()
		#Removes any rooms with no available links
		while openLinks[selectedLinkRoom].is_empty():
			openLinks.erase(selectedLinkRoom)
			if openLinks.is_empty():
				return
			selectedLinkRoom = openLinks.keys().pick_random()
		var selectedLink : Dictionary = openLinks[selectedLinkRoom].pick_random()
		var possibleRooms : Array = []
		for piece in dungeonPieces:
			for link in piece["structure"]["link_blocks"]:
				if (selectedLink.has("group") and link.has("group") and selectedLink["group"] == link["group"]) or (!selectedLink.has("group") and !link.has("group")):
					var side1 = link["side"]
					var side2 = selectedLink["side"]
					if (side1.x == -side2.x and side1.x != 0) or (side1.y == -side2.y and side1.y != 0):
						possibleRooms.append({"piece":piece,"link":link})
						break
		var roomChosen = false
		while !roomChosen and !possibleRooms.is_empty():
			var chosenRoom = possibleRooms.pick_random()
			var link1Pos = selectedLink["position"] + dungeon[selectedLinkRoom]["position"]
			var link2 = chosenRoom["link"]
			var originPos : Vector2
			if link2["side"].x != 0:
				originPos = Vector2(link1Pos.x+selectedLink["side"].x-(chosenRoom["piece"]["size"].x-1 if selectedLink["side"].x < 0 else 0),-(link2["position"].y-link1Pos.y))
			else:
				originPos = Vector2(-(link2["position"].x-link1Pos.x),link1Pos.y+selectedLink["side"].y-(chosenRoom["piece"]["size"].y-1 if selectedLink["side"].y < 0 else 0))
			var canPlace = true
			for oldRoom in dungeon:
				if Rect2(dungeon[oldRoom]["position"],dungeon[oldRoom]["size"]).intersects(Rect2(originPos,chosenRoom["piece"]["size"])) or !Rect2(Vector2(0,0),worldSize).encloses(Rect2(originPos,chosenRoom["piece"]["size"])) or (keepOnGround and originPos.y + chosenRoom["piece"]["size"].y < (worldSize.y - (int(worldNoise.get_noise_1d(originPos.x) * noiseScale) + worldHeight))):
					canPlace = false
			if canPlace:
				dungeon[currentId] = {"position":originPos,"size":chosenRoom["piece"]["size"]}
				openLinks[selectedLinkRoom].erase(selectedLink)
				if openLinks[selectedLinkRoom].is_empty():
					openLinks.erase(selectedLinkRoom)
				openLinks[currentId] = []
				for link in chosenRoom["piece"]["structure"]["link_blocks"]:
					if link["position"] != link2["position"]:
						openLinks[currentId].append(link)
				for block in chosenRoom["piece"]["structure"]["blocks"]:
					if replaceFloorBlock.is_empty() or !replaceFloorBlock.has(block["id"]):
						generate_block_from_structure(block,block["position"] + originPos)
				roomChosen = true
			else:
				possibleRooms.erase(chosenRoom)

func generate_block_from_structure(block : Dictionary, pos : Vector2) -> void:
	var gen : RandomNumberGenerator = RandomNumberGenerator.new()
	gen.randomize()
	match block["id"]:
		187:
			set_block(pos,block["layer"],0,false)
		189:
			var usedGroups = []
			var chest = []
			if lootTables.has(block["data"]["group"]):
				while chest.size() < 2:
					for loot in lootTables[block["data"]["group"]]:
						if !usedGroups.has(loot["group"]):
							var amount : int = 0
							for i in range(loot["amount"]):
								amount += 1 if gen.randi_range(0,loot["rarity"]) == 0 else 0
							if amount > 0:
								var data : Dictionary = {}
								match loot["id"]:
									215:
										data = {"upgrade":upgrades.keys()[gen.randi() % upgrades.keys().size()]}
								if loot["group"] != "none":
									usedGroups.append(loot["group"])
								chest.append({"id":loot["id"],"amount":amount,"data":data})
			set_block(pos,block["layer"],91,false,chest)
		_:
			set_block(pos,block["layer"],block["id"],false,block["data"])

func get_world_data() -> Dictionary:
	var data = {}
	data["player"] = {
		"armor":armor.armor,"inventory":inventory.inventory,"inventory_refs":{"j":inventory.jRef,"k":inventory.kRef},"health":player.health,"max_health":player.maxHealth,"oxygen":player.oxygen,"suit_oxygen":player.suitOxygen,"max_oxygen":player.maxOxygen,"suit_oxygen_max":player.suitOxygenMax,"current_planet":Global.currentPlanet,"current_system":Global.currentSystemId,"pos":player.position,"save_type":"planet","achievements":GlobalGui.completedAchievements,
		"misc_stats":{"meteor_stage":meteors.stage,"meteor_progress_time_left":$"../CanvasLayer/Environment/Meteors/StageProgress".time_left}
	}
	data["system"] = StarSystem.get_system_data()
	data["planet"] = {"blocks":get_blocks_data(),"entities":entities.get_entity_data(),"rules":worldRules,"left_at_time":Global.globalGameTime,"current_weather":$"..".currentWeather,"weather_time_left":$"../weather/WeatherTimer".time_left,"wires":[]}
	for wire in $Wires.get_children():
		data["planet"]["wires"].append({"output_block_pos":wire.outputBlock.pos,"output_block_layer":wire.outputBlock.layer,"output_pin":wire.outputPin,"input_block_pos":wire.inputBlock.pos,"input_block_layer":wire.inputBlock.layer,"input_pin":wire.inputPin})
	return data

func get_blocks_data(withinArea : bool = false,area : Rect2 = Rect2()) -> Array:
	var blocks = []
	for block in $blocks.get_children():
		if (GlobalData.blockData[block.id]["type"] != "door" or block.mainBlock == block) and (!withinArea or area.has_point(block.pos)):
			if block.id == 186:
				print(block.data)
			blocks.append({"id":block.id,"layer":block.layer,"position":block.pos if !withinArea else block.pos - area.position ,"data":block.data})
	return blocks

func get_structure_blocks(area : Rect2) -> Dictionary:
	var blocks = {"blocks":[],"link_blocks":[]}
	for block in $blocks.get_children():
		if (GlobalData.blockData[block.id]["type"] != "door" or block.mainBlock == block) and area.has_point(block.pos):
			match block.id:
				185:
					var pos = block.pos - area.position
					var xSide = -1 if pos.x < 1 else (1 if pos.x == area.size.x-1 else 0)
					var ySide = -1 if pos.y < 1 else (1 if pos.y == area.size.y-1 else 0)
					var linkData = {"side":Vector2(xSide,ySide),"position":pos}
					if !block.data["group"].is_empty():
						linkData["group"] = block.data["group"]
					blocks["link_blocks"].append(linkData)
					blocks["blocks"].append({"id":187,"layer":block.layer,"position":block.pos - area.position,"data":block.data})
				_:
					blocks["blocks"].append({"id":block.id,"layer":block.layer,"position":block.pos - area.position ,"data":block.data})
	return blocks

func load_player_data() -> void:
	#Loads player data
	var playerData = Global.playerData.duplicate(true)
	print("INVENTORY: ", playerData["inventory"])
	Global.playerBase = {"skin":playerData["skin"],"hair_style":playerData["hair_style"],"hair_color":playerData["hair_color"],"sex":playerData["sex"],"eye_color":playerData["eye_color"],"eye_style":playerData["eye_style"]}
	player.get_node("Textures/body").modulate = playerData["skin"]
	if !["male","female"].has(playerData["sex"]): #Ensures parity with pre TU6 saves
		playerData["sex"] = {"Guy":"male","Woman":"female"}[playerData["sex"]]
	player.gender = playerData["sex"]
	player.health = playerData["health"]
	player.oxygen = playerData["oxygen"]
	player.suitOxygen = playerData["suit_oxygen"]
	player.maxHealth = playerData["max_health"]
	player.maxOxygen = playerData["max_oxygen"]
	player.suitOxygenMax = playerData["suit_oxygen_max"]
	var inventorySet : Array = playerData["inventory"]
	for item : Dictionary in inventorySet: #adds item data to every item in the inventory if before TU5
		if !item.has("data"):
			item["data"] = {}
	inventory.inventory = inventorySet
	armor.armor = playerData["armor"]
	armor.emit_signal("updated_armor",armor.armor)
	if playerData.has("inventory_refs"):
		inventory.jRef = playerData["inventory_refs"]["j"]
		inventory.kRef = playerData["inventory_refs"]["k"]
		inventory.update_inventory()

func load_world_data() -> void:#data : Dictionary) -> void:
	#Loads planet data
	var planetData = Global.load_planet(Global.currentSystemId,Global.currentPlanet)
	entities.load_entities(planetData["entities"])
	var setRules = worldRules.duplicate(true)
	if planetData.has("rules"):
		setRules = planetData["rules"]
		for rule in worldRules:
			if !setRules.has(rule):
				setRules[rule] = worldRules[rule]
	worldRules = setRules
	meteors.stage = 0 if !Global.playerData.has("misc_stats") or !Global.playerData["misc_stats"].has("meteor_stage") else Global.playerData["misc_stats"]["meteor_stage"]
	meteors.savedProgressTime = 60 if !Global.playerData.has("misc_stats") or !Global.playerData["misc_stats"].has("meteor_progress_time_left") else Global.playerData["misc_stats"]["meteor_progress_time_left"]
	if planetData.has("weather_time_left"):
		var timeElapsed = Global.globalGameTime - planetData["left_at_time"]
		if planetData["current_weather"] != "none" and timeElapsed < planetData["weather_time_left"]: #Sets weather to what it was if not enough time has passed
			$"..".set_weather(false,[planetData["weather_time_left"]-timeElapsed,planetData["weather_time_left"]-timeElapsed],planetData["current_weather"],false)
	if Global.playerData.has("pos") and Global.playerData["save_type"] == "planet":
		player.position = Global.playerData["pos"]
	elif worldRules["world_spawn_x"]["value"] >= 0 and worldRules["world_spawn_y"]["value"] >= 0:
		player.position = Vector2(worldRules["world_spawn_x"]["value"]*4,worldRules["world_spawn_y"]["value"]*4)
	for block in planetData["blocks"]:
		set_block(block["position"],block["layer"],block["id"],false,block["data"])
	if planetData.has("wires"): #For older versions
		for wireData in planetData["wires"]:
			var wire = WIRE.instantiate()
			wire.outputBlock = get_block(wireData["output_block_pos"],wireData["output_block_layer"])
			wire.inputBlock = get_block(wireData["input_block_pos"],wireData["input_block_layer"])
			wire.outputPin = wireData["output_pin"]
			wire.inputPin = wireData["input_pin"]
			$Wires.add_child(wire)
			wire.setup()

func get_block(pos : Vector2, layer : int) -> Object:
	if $blocks.has_node(str(pos.x) + "," + str(pos.y) + "," + str(layer)):
		return $blocks.get_node(str(pos.x) + "," + str(pos.y) + "," + str(layer))
	return null

func get_block_id(pos : Vector2, layer : int) -> int:
	if get_block(pos,layer) != null:
		return get_block(pos,layer).id
	return 0

func set_light(pos : Vector2, lightMapValue : Color, lightIntensityMapValue : Color, updateMaps := true) -> void:
	lightIntensityMap.set_pixelv(pos,lightIntensityMapValue)
	lightMap.set_pixelv(pos,lightMapValue)
	if updateMaps:
		update_light_texture()

func set_block_all(pos: Vector2, id : int) -> void:
	set_block(pos,0,id)
	set_block(pos,1,id)

func get_light_intensity(intensity : int) -> Color:
	return Color((("0" + str(intensity)) if intensity < 10 else str(intensity)) + "000005")

func set_block(pos : Vector2, layer : int, id : int, update = false, data = {}) -> void:
	var blockAtPos = get_block(pos,layer)
	if blockAtPos != null or (id == 0 and blockAtPos != null):
		$blocks.remove_child(blockAtPos)
		if GlobalData.blockData[blockAtPos.id]["type"] == "door":
			blockAtPos.emit_signal("destroyed")
		blockAtPos.queue_free()
		if id == 0:
			match layer:
				0:
					if GlobalData.blockData[get_block_id(pos,1)]["transparent"] and pos.y < lightFalloffHeight:
						set_light(pos,Color.WHITE,Color("FF000005"),update)
				1:
					if GlobalData.blockData[get_block_id(pos,0)]["transparent"] and pos.y < lightFalloffHeight:
						set_light(pos,Color.WHITE,Color("FF000005"),update)
					else:
						set_light(pos,Color("00000000"),Color("00000000"),update)
	if id > 0:
		var block = blockTypes[GlobalData.blockData[id]["type"]].instantiate()
		var block_data = GlobalData.get_item_data(id)
		match layer:
			0:
				if GlobalData.blockData[get_block_id(pos,1)]["transparent"]:
					if block_data.has("light_color"):
						set_light(pos,Color(block_data["light_color"]),get_light_intensity(block_data["light_intensity"]),update)
					elif !block_data["transparent"] or pos.y >= lightFalloffHeight:
						set_light(pos,Color("00000000"),Color("00000000"),update)
			1:
				if !GlobalData.blockData[id]["transparent"]:
					if block_data.has("light_color"):
						set_light(pos,block_data["light_color"],get_light_intensity(block_data["light_intensity"]),update)
					else:
						set_light(pos,Color.BLACK,Color.BLACK,update)
				elif block_data.has("light_color"):
					set_light(pos,block_data["light_color"],get_light_intensity(block_data["light_intensity"]),update)
		block.position = pos * BLOCK_SIZE
		block.pos = pos
		block.id = id
		block.layer = layer
		block.data = data
		block.name = str(pos.x) + "," + str(pos.y) + "," + str(layer)
		if block.has_node("Sprite2D"):
			block.get_node("Sprite2D").texture = GlobalData.get_item_texture(id)
		$blocks.add_child(block)
		if GlobalData.blockData[id]["type"] == "door": #adds ghost blocks for door
			for y in [-1,1]:
				var newBlockAtPos = get_block(pos + Vector2(0,y),layer)
				if newBlockAtPos != null:
					$blocks.remove_child(newBlockAtPos)
					if GlobalData.blockData[newBlockAtPos.id]["type"] == "door":
						newBlockAtPos.emit_signal("destroyed")
					newBlockAtPos.queue_free()
				var ghostBlock = blockTypes["ghost"].instantiate()
				ghostBlock.destroyed.connect(block.ghost_block_block_destroyed)
				ghostBlock.position = (pos + Vector2(0,y)) * BLOCK_SIZE
				ghostBlock.mainBlock = block
				ghostBlock.pos = pos + Vector2(0,y)
				ghostBlock.id = id
				ghostBlock.name = str(pos.x) + "," + str(pos.y+y) + "," + str(layer)
				$blocks.add_child(ghostBlock)
	emit_signal("blocks_changed")
	if update:
		update_area(pos)

func update_area(pos):
	for x in range(pos.x-1,pos.x+2):
		for y in range(pos.y-1,pos.y+2):
			if Vector2(x,y) != pos and get_block(Vector2(x,y),1) != null:
				get_block(Vector2(x,y),1).on_update()
			if get_block(Vector2(x,y),0) != null:
				get_block(Vector2(x,y),0).on_update()

func update_light_texture() -> void:
	$"../LightRenderViewport/LightRender".get_node("LightingViewport/SubViewport/LightRect").material.set_shader_parameter("light_map",ImageTexture.create_from_image(lightMap))
	$"../LightRenderViewport/LightRender".get_node("LightingViewport/SubViewport/LightRect").material.set_shader_parameter("light_intensity_map",ImageTexture.create_from_image(lightIntensityMap))

func build_event(action : String, pos : Vector2, layer : int,id = 0, itemAction = true) -> void:
	if action == "Build" and [0,6,7,117].has(get_block_id(pos,layer)) and GlobalData.blockData.has(id) and (!GlobalData.blockData[id].has("can_place_on") or GlobalData.blockData[id]["can_place_on"].has(float(get_block_id(pos + Vector2(0,1),layer)))):
		var canPlace = true
		if GlobalData.blockData[id]["type"] == "door": #Makes sure all blocks are clear for the door
			if [0,6,7,117].has(get_block_id(pos + Vector2(0,2),layer)):
				canPlace = false
			for y in [-1,1]:
				if ![0,6,7,117].has(get_block_id(pos + Vector2(0,y),layer)):
					canPlace = false
		if canPlace:
			GlobalAudio.play_block_audio_2d(id,"place",pos * BLOCK_SIZE)
			set_block(pos,layer,id,true)
			if itemAction:
				inventory.remove_id_from_inventory(id,1)
	elif action == "Break" and get_block(pos,layer) != null:
		var block : int = get_block_id(pos,layer)
		GlobalAudio.play_block_audio_2d(block,"break",pos * BLOCK_SIZE)
		match block:
			91:
				for item in get_block(pos,layer).data:
					entities.spawn_item({"id":item["id"],"amount":item["amount"],"data":item["data"]},false,pos*BLOCK_SIZE)
		if itemAction and !Global.godmode:
			var itemsToDrop = GlobalData.blockData[block]["drops"]
			if fullGrownItemDrops.has(block) and get_block(pos,layer).data["plant_stage"] >= 3:
				itemsToDrop = fullGrownItemDrops[block]
			for i in range(itemsToDrop.size()):
				if typeof(itemsToDrop[i]["amount"]) != TYPE_ARRAY:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":itemsToDrop[i]["amount"],"data":{}},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],itemsToDrop[i]["amount"])
				else:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":int(randf_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1)),"data":{}},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1)))
		set_block(pos,layer,0,true)

func _on_GoUp_pressed():
	Global.save("planet", get_world_data())
	if Global.currentSystemId == "2340163271682" and Global.currentPlanet == 1:
		Global.teleport_to_planet(Global.playerData["original_system"],Global.playerData["original_planet"])
	else:
		StarSystem.start_space()

func _on_GlobalTick_timeout():
	var toRemove = []
	for water in waterUpdateList:
		if is_instance_valid(water):
			water._on_Tick_timeout()
		else:
			toRemove.append(water)
	for remove in toRemove:
		waterUpdateList.erase(remove)
	var updatedPos = []
	for water in waterUpdateList:
		if is_instance_valid(water):
			water.update_water_texture()
			water.on_update()
			updatedPos.append({"pos":water.pos,"layer":water.layer})
			for x in range(water.pos.x-1,water.pos.x+2):
				for y in range(water.pos.y-1,water.pos.y+2):
					var blockLayer1 = get_block(Vector2(x,y),1)
					var blockLayer2 = get_block(Vector2(x,y),0)
					if !updatedPos.has({"pos":Vector2(x,y),"layer":1}) and blockLayer1 != null:
						blockLayer1.on_update()
						updatedPos.append({"pos":Vector2(x,y),"layer":1})
					if !updatedPos.has({"pos":Vector2(x,y),"layer":0}) and blockLayer2 != null:
						blockLayer2.on_update()
						updatedPos.append({"pos":Vector2(x,y),"layer":0})
