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

@onready var inventory = $"../CanvasLayer/Inventory"
@onready var enviroment = $"../CanvasLayer/Enviroment"
@onready var armor = $"../CanvasLayer/Inventory/Armor"
@onready var player = $"../Player"
@onready var entities = $"../Entities"
@onready var meteors = $"../CanvasLayer/Enviroment/Meteors"

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

var interactableBlocks = [12,16,28,91,145,158,159,167,169,171,176,185,186,189,216,241,243,244,246,263]
var noCollisionBlocks = [0,6,7,9,11,30,117,167,121,122,123,128,142,143,145,155,156,167,168,169,170,171,172,187]
var transparentBlocks = [0,1,6,7,9,11,12,20,24,10,28,30,69,76,79,80,81,85,91,117,119,120,121,122,123,145,158,159,155,156,154,146,160,161,167,171,172,176,183,187,188,189,190,199,203,204,206,217,218,219,220,242,244,246,264,265,266,267,268,269,270,271,272]

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

var blockData = {
	1:{"texture":preload("res://textures/blocks/grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":1,"amount":1}],"name":"Grass block","type":"block"},
	2:{"texture":preload("res://textures/blocks/dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Dirt","type":"simple"},
	3:{"texture":preload("res://textures/blocks/stone.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Stone","type":"simple"},
	6:{"texture":preload("res://textures/items/yellow_flower.png"),"hardness":0.1,"breakWith":"All","canHaverst":0,"drops":[{"id":6,"amount":1}],"name":"Yellow Flower","can_place_on":[1,2,146,147],"type":"foliage"},
	7:{"texture":preload("res://textures/items/pink_flower.png"),"hardness":0.1,"breakWith":"All","canHaverst":0,"drops":[{"id":7,"amount":1}],"name":"Pink Flower","can_place_on":[1,2,146,147],"type":"foliage"},
	8:{"texture":preload("res://textures/blocks/Cobble.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Cobble","type":"simple"},
	9:{"texture":preload("res://textures/blocks/sapling.png"),"hardness":7,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":[3,6]},{"id":11,"amount":[0,3]}],"name":"Tree","type":"foliage"},
	10:{"texture":preload("res://textures/blocks/log_front.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":1}],"name":"Log","type":"block"},
	11:{"texture":preload("res://textures/items/pinecone.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":11,"amount":1}],"name":"Pinecone","can_place_on":[1,2,24],"type":"foliage"},
	12:{"texture":preload("res://textures/blocks/crafting_table.png"),"hardness":2,"breakWith":"Axe","canHaverst":1,"drops":[{"id":12,"amount":1}],"name":"Workbench","type":"simple"},
	13:{"texture":preload("res://textures/blocks/planks.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":13,"amount":1}],"name":"Planks","type":"simple"},
	14:{"texture":preload("res://textures/blocks/sand.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":14,"amount":1}],"name":"Sand","type":"block"},
	15:{"texture":preload("res://textures/blocks/stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":15,"amount":1}],"name":"Stone bricks","type":"simple"},
	16:{"texture":preload("res://textures/blocks/oven.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":16,"amount":1}],"name":"Oven","type":"simple"},
	17:{"texture":preload("res://textures/blocks/mud_stone.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":17,"amount":1}],"name":"Mud stone","type":"simple"},
	18:{"texture":preload("res://textures/blocks/mud_stone_dust.png"),"hardness":0.5,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":18,"amount":1}],"name":"Mud stone dust","type":"block"},
	19:{"texture":preload("res://textures/blocks/mud_stone_bricks.png"),"hardness":1.4,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":19,"amount":1}],"name":"Mud stone bricks","type":"simple"},
	20:{"texture":preload("res://textures/blocks/glass_icon.png"),"hardness":0.1,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":20,"amount":1}],"name":"Glass","type":"block"},
	21:{"texture":preload("res://textures/blocks/snow_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":21,"amount":1}],"name":"Snow block","type":"simple"},
	22:{"texture":preload("res://textures/blocks/sandstone.png"),"hardness":1.3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":22,"amount":1}],"name":"Sandstone","type":"simple"},
	23:{"texture":preload("res://textures/blocks/sandstone_bricks.png"),"hardness":2.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":23,"amount":1}],"name":"Sandstone bricks","type":"simple"},
	24:{"texture":preload("res://textures/blocks/grass_snow.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":24,"amount":1}],"name":"Grass snow","type":"block"},
	25:{"texture":preload("res://textures/blocks/clay.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":25,"amount":1}],"name":"Clay","type":"simple"},
	26:{"texture":preload("res://textures/blocks/bricks.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":26,"amount":1}],"name":"Bricks","type":"simple"},
	27:{"texture":preload("res://textures/blocks/brick_shingles.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":27,"amount":1}],"name":"Brick shingles","type":"simple"},
	28:{"texture":preload("res://textures/blocks/smithing_table.png"),"hardness":2.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":28,"amount":1}],"name":"Smithing table","type":"simple"},
	29:{"texture":preload("res://textures/blocks/copper_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":29,"amount":1}],"name":"Copper ore","type":"simple"},
	30:{"texture":preload("res://textures/blocks/platform_full.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":30,"amount":1}],"name":"Wood platform","type":"platform"},
	55:{"texture":preload("res://textures/blocks/silver_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":55,"amount":1}],"name":"Silver ore","type":"simple"},
	69:{"texture":preload("res://textures/blocks/exotic_grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":69,"amount":1}],"name":"Exotic grass block","type":"simple"},
	70:{"texture":preload("res://textures/blocks/exotic_dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":70,"amount":1}],"name":"Exotic dirt","type":"simple"},
	71:{"texture":preload("res://textures/blocks/exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":71,"amount":1}],"name":"Exotic stone","type":"simple"},
	72:{"texture":preload("res://textures/blocks/exotic_stone_bricks.png"),"hardness":3.5,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":72,"amount":1}],"name":"Exotic stone bricks","type":"simple"},
	73:{"texture":preload("res://textures/blocks/rhodonite_ore.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":74,"amount":1}],"name":"Rhodonite ore","type":"simple"},
	75:{"texture":preload("res://textures/blocks/carved_exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":75,"amount":1}],"name":"Carved exotic stone","type":"simple"},
	76:{"texture":preload("res://textures/blocks/exotic_sapling.png"),"hardness":9,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":[3,6]},{"id":85,"amount":[0,3]}],"name":"Exotic tree","type":"foliage"},
	77:{"texture":preload("res://textures/blocks/exotic_log_front.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":1}],"name":"Exotic log","type":"block"},
	78:{"texture":preload("res://textures/blocks/exotic_planks.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":78,"amount":1}],"name":"Exotic planks","type":"simple"},
	79:{"texture":preload("res://textures/blocks/exotic_wood_window.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":79,"amount":1}],"name":"Exotic wood window","type":"block"},
	80:{"texture":preload("res://textures/blocks/wood_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":80,"amount":1}],"name":"Wood window","type":"block"},
	81:{"texture":preload("res://textures/blocks/copper_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":81,"amount":1}],"name":"Copper window","type":"block"},
	82:{"texture":preload("res://textures/blocks/mossy_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":82,"amount":1}],"name":"Mossy stone bricks","type":"simple"},
	83:{"texture":preload("res://textures/blocks/cracked_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":83,"amount":1}],"name":"Cracked stone bricks","type":"simple"},
	84:{"texture":preload("res://textures/blocks/mossy_cobblestone.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":84,"amount":1}],"name":"Mossy cobble","type":"simple"},
	85:{"texture":preload("res://textures/blocks/exotic_sapling.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":85,"amount":1}],"name":"Exotic sapling","can_place_on":[69,70],"type":"foliage"},
	86:{"texture":preload("res://textures/blocks/cracked_mud_bricks.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":86,"amount":1}],"name":"Cracked mud bricks","type":"simple"},
	87:{"texture":preload("res://textures/blocks/cracked_sandstone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":87,"amount":1}],"name":"Cracked sandstone bricks","type":"simple"},
	88:{"texture":preload("res://textures/blocks/copper_block.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":88,"amount":1}],"name":"Copper block","type":"simple"},
	89:{"texture":preload("res://textures/blocks/silver_block.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":89,"amount":1}],"name":"Silver block","type":"simple"},
	90:{"texture":preload("res://textures/blocks/rhodonite_block.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":90,"amount":1}],"name":"Rhodonite block","type":"simple"},
	91:{"texture":preload("res://textures/blocks/chest.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":91,"amount":1}],"name":"Chest","type":"block"},
	104:{"texture":preload("res://textures/blocks/quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":100,"amount":[1,3]}],"name":"Quartz ore","type":"simple"},
	105:{"texture":preload("res://textures/blocks/rose_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":101,"amount":[1,3]}],"name":"Rose quartz ore","type":"simple"},
	106:{"texture":preload("res://textures/blocks/purple_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":102,"amount":[1,3]}],"name":"Purple quartz ore","type":"simple"},
	107:{"texture":preload("res://textures/blocks/blue_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":103,"amount":[1,3]}],"name":"Blue quartz ore","type":"simple"},
	108:{"texture":preload("res://textures/blocks/quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":108,"amount":1}],"name":"Quartz block","type":"simple"},
	109:{"texture":preload("res://textures/blocks/rose_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":109,"amount":1}],"name":"Rose quartz block","type":"simple"},
	110:{"texture":preload("res://textures/blocks/purple_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":110,"amount":1}],"name":"Purple quartz block","type":"simple"},
	111:{"texture":preload("res://textures/blocks/blue_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":111,"amount":1}],"name":"Blue quartz block","type":"simple"},
	112:{"texture":preload("res://textures/blocks/asteroid_rock.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":112,"amount":1}],"name":"Asteroid rock","type":"simple"},
	117:{"texture":preload("res://textures/blocks/water/water_4.png"),"hardness":0,"breakWith":"None","canHaverst":0,"drops":[],"name":"Water","type":"water"},
	118:{"texture":preload("res://textures/blocks/wet_sand.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":118,"amount":1}],"name":"Wet sand","type":"simple"},
	119:{"texture":preload("res://textures/blocks/farmland_dry.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Farmland","type":"block"},
	120:{"texture":preload("res://textures/blocks/farmland_wet.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Wet farmland","type":"simple"},
	121:{"texture":preload("res://textures/items/wheat_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":121,"amount":1}],"name":"Wheat seeds","can_place_on":[119,120],"type":"foliage"},
	122:{"texture":preload("res://textures/items/tomato_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":122,"amount":1}],"name":"Tomato seeds","can_place_on":[119,120],"type":"foliage"},
	123:{"texture":preload("res://textures/items/corn_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":123,"amount":1}],"name":"Corn seeds","can_place_on":[119,120],"type":"foliage"},
	124:{"texture":preload("res://textures/blocks/rhodonite_ore_stone.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":74,"amount":1}],"name":"Rhodonite stone ore","type":"simple"},
	128:{"texture":preload("res://textures/items/fig_tree.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":121,"amount":[0,1]},{"id":122,"amount":[0,1]},{"id":123,"amount":[0,1]},{"id":221,"amount":[0,1]}],"name":"Fig tree","can_place_on":[1,2],"type":"foliage"},
	133:{"texture":preload("res://textures/blocks/copper_plate.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":133,"amount":1}],"name":"Copper plate","type":"simple"},
	134:{"texture":preload("res://textures/blocks/copper_bricks.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":134,"amount":1}],"name":"Copper bricks","type":"simple"},
	135:{"texture":preload("res://textures/blocks/cracked_copper_bricks.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":135,"amount":1}],"name":"Cracked copper bricks","type":"simple"},
	136:{"texture":preload("res://textures/blocks/silver_plate.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":136,"amount":1}],"name":"Silver plate","type":"simple"},
	137:{"texture":preload("res://textures/blocks/silver_bricks.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":137,"amount":1}],"name":"Silver bricks","type":"simple"},
	138:{"texture":preload("res://textures/blocks/cracked_silver_bricks.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":138,"amount":1}],"name":"Silver bricks","type":"simple"},
	139:{"texture":preload("res://textures/blocks/lily_mart.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Lily Mart","type":"lily_mart"},
	141:{"texture":preload("res://textures/blocks/skips_stones.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Skip's stones","type":"skips_stones"},
	142:{"texture":preload("res://textures/blocks/posters/poster_icon.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":142,"amount":1}],"name":"Poster 1","type":"foliage"},
	143:{"texture":preload("res://textures/blocks/posters/poster_icon.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":143,"amount":1}],"name":"Poster 2","type":"foliage"},
	144:{"texture":preload("res://textures/blocks/bottom_rock.png"),"hardness":0,"breakWith":"Pickaxe","canHaverst":100,"drops":[{"id":144,"amount":1}],"name":"Bottom rock","type":"simple"},
	145:{"texture":preload("res://textures/blocks/sign_empty.png"),"hardness":0.5,"breakWith":"Axe","canHaverst":0,"drops":[{"id":145,"amount":1}],"name":"Wood sign","type":"sign"},
	146:{"texture":preload("res://textures/blocks/dry_grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":146,"amount":1}],"name":"Dry grass block","type":"block"},
	147:{"texture":preload("res://textures/blocks/dry_dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":147,"amount":1}],"name":"Dry dirt","type":"simple"},
	148:{"texture":preload("res://textures/blocks/pink_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":148,"amount":1}],"name":"Pink granite","type":"simple"},
	149:{"texture":preload("res://textures/blocks/white_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":149,"amount":1}],"name":"White granite","type":"simple"},
	150:{"texture":preload("res://textures/blocks/brown_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":150,"amount":1}],"name":"Brown granite","type":"simple"},
	151:{"texture":preload("res://textures/blocks/pink_iron_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":151,"amount":1}],"name":"Iron ore","type":"simple"},
	152:{"texture":preload("res://textures/blocks/white_iron_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":152,"amount":1}],"name":"Iron ore","type":"simple"},
	153:{"texture":preload("res://textures/blocks/brown_iron_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":153,"amount":1}],"name":"Iron ore","type":"simple"},
	154:{"texture":preload("res://textures/blocks/acacia_log_front.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":154,"amount":1}],"name":"Acacia log","type":"block"},
	155:{"texture":preload("res://textures/blocks/plants/acacia_tree/acacia_tree_sapling.png"),"hardness":7,"breakWith":"Axe","canHaverst":1,"drops":[{"id":154,"amount":[3,6]},{"id":156,"amount":[0,3]}],"name":"Acacia tree","type":"foliage"},
	156:{"texture":preload("res://textures/blocks/plants/acacia_tree/acacia_tree_sapling.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":156,"amount":1}],"name":"Acacia sapling","can_place_on":[146,147],"type":"foliage"},
	157:{"texture":preload("res://textures/blocks/acacia_planks.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":157,"amount":1}],"name":"Acacia planks","type":"simple"},
	158:{"texture":preload("res://textures/blocks/acacia_crafting_table.png"),"hardness":2,"breakWith":"Axe","canHaverst":1,"drops":[{"id":158,"amount":1}],"name":"Workbench","type":"simple"},
	159:{"texture":preload("res://textures/blocks/acacia_chest.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":159,"amount":1}],"name":"Chest","type":"block"},
	160:{"texture":preload("res://textures/blocks/plants/grass.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Grass","can_place_on":[1,2,146,147],"type":"foliage"},
	161:{"texture":preload("res://textures/blocks/plants/tall_grass.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Tall grass","can_place_on":[1,2,146,147],"type":"foliage"},
	162:{"texture":preload("res://textures/blocks/polished_pink_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":162,"amount":1}],"name":"Polished pink granite","type":"simple"},
	163:{"texture":preload("res://textures/blocks/polished_white_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":163,"amount":1}],"name":"Polished white granite","type":"simple"},
	164:{"texture":preload("res://textures/blocks/polished_brown_granite.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":164,"amount":1}],"name":"Polished brown granite","type":"simple"},
	167:{"texture":preload("res://textures/blocks/lever_off.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":167,"amount":1}],"name":"Lever","type":"lever"},
	168:{"texture":preload("res://textures/blocks/display_block_off.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":168,"amount":1}],"name":"Display block","type":"display_block"},
	169:{"texture":preload("res://textures/blocks/logic_block_and.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":169,"amount":1}],"name":"Logic block","type":"logic_block"},
	170:{"texture":preload("res://textures/blocks/flip_block_off.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":170,"amount":1}],"name":"Flip block","type":"flip_block"},
	171:{"texture":preload("res://textures/items/door_icon.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":171,"amount":1}],"name":"Wood door","type":"door","door_animation":preload("res://textures/blocks/misc/wood_door.tres")},
	172:{"texture":preload("res://textures/items/steel_door_icon.png"),"hardness":4,"canHaverst":3,"drops":[{"id":172,"amount":1}],"name":"Steel door","type":"door","door_animation":preload("res://textures/blocks/misc/steel_door.tres")},
	173:{"texture":preload("res://textures/blocks/steel.png"),"hardness":5,"canHaverst":3,"drops":[{"id":173,"amount":1}],"name":"Steel","type":"block"},
	174:{"texture":preload("res://textures/blocks/steel_taped.png"),"hardness":4,"canHaverst":3,"drops":[{"id":174,"amount":1}],"name":"Taped steel","type":"simple"},
	175:{"texture":preload("res://textures/blocks/steel_tiles.png"),"hardness":4,"canHaverst":3,"drops":[{"id":175,"amount":1}],"name":"Steel tiles","type":"simple"},
	176:{"texture":preload("res://textures/blocks/button_off.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":176,"amount":1}],"name":"Button","type":"button"},
	177:{"texture":preload("res://textures/blocks/scorched_rock.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":177,"amount":1}],"name":"Scorched rock","type":"simple"},
	178:{"texture":preload("res://textures/blocks/scorched_pebbles.png"),"hardness":0.5,"canHaverst":1,"drops":[{"id":178,"amount":1}],"name":"Scorched pebbles","type":"simple"},
	179:{"texture":preload("res://textures/blocks/scorched_iron_ore.png"),"hardness":3.5,"canHaverst":3,"drops":[{"id":179,"amount":1}],"name":"Scorched iron ore","type":"simple"},
	180:{"texture":preload("res://textures/blocks/scorched_bricks_1.png"),"hardness":1,"canHaverst":1,"drops":[{"id":180,"amount":1}],"name":"Scorched bricks","type":"block"},
	181:{"texture":preload("res://textures/blocks/carved_scorched_bricks.png"),"hardness":1,"canHaverst":1,"drops":[{"id":181,"amount":1}],"name":"Carved scorched bricks","type":"simple"},
	182:{"texture":preload("res://textures/blocks/magma_scorched_bricks.png"),"hardness":1,"canHaverst":1,"drops":[{"id":182,"amount":1}],"name":"Magma scorched bricks","type":"simple"},
	183:{"texture":preload("res://textures/blocks/scorched_brick_fence.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":183,"amount":1}],"name":"Scorched brick fence","type":"block"},
	184:{"texture":preload("res://textures/blocks/magma.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":184,"amount":1}],"name":"Magma","type":"simple"},
	185:{"texture":preload("res://textures/blocks/dev_link.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":185,"amount":1}],"name":"Dev link block","type":"block"},
	186:{"texture":preload("res://textures/blocks/structure_save.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":186,"amount":1}],"name":"Structure save block","type":"block"},
	187:{"texture":preload("res://textures/blocks/air_hold.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Air hold","type":"foliage"},
	188:{"texture":preload("res://textures/blocks/scorched_platform_full.png"),"hardness":1,"canHaverst":1,"drops":[{"id":188,"amount":1}],"name":"Scorched platform","type":"platform"},
	189:{"texture":preload("res://textures/blocks/dev_chest.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":189,"amount":1}],"name":"Dev chest","type":"block"},
	190:{"texture":preload("res://textures/blocks/scorched_spawner.png"),"hardness":6,"canHaverst":2,"drops":[],"name":"Scorched spawner","type":"spawner"},
	192:{"texture":preload("res://textures/blocks/sandstone_gold_ore.png"),"hardness":4,"canHaverst":3,"drops":[{"id":192,"amount":1}],"name":"Gold ore","type":"simple"},
	194:{"texture":preload("res://textures/blocks/gold_ore.png"),"hardness":5,"canHaverst":3,"drops":[{"id":194,"amount":1}],"name":"Gold ore","type":"simple"},
	195:{"texture":preload("res://textures/blocks/gold_block.png"),"hardness":5,"canHaverst":3,"drops":[{"id":195,"amount":1}],"name":"Gold block","type":"simple"},
	196:{"texture":preload("res://textures/items/desert_bush.png"),"hardness":0.1,"canHaverst":0,"drops":[{"id":196,"amount":1}],"name":"Desert shrub","can_place_on":[1,2,146,147,14],"type":"foliage"},
	197:{"texture":preload("res://textures/blocks/permafrost.png"),"hardness":2.5,"canHaverst":1,"drops":[{"id":197,"amount":1}],"name":"Permafrost","type":"simple"},
	198:{"texture":preload("res://textures/blocks/permafrost_slush.png"),"hardness":0.8,"canHaverst":0,"drops":[{"id":198,"amount":1}],"name":"Permafrost slush","type":"simple"},
	199:{"texture":preload("res://textures/blocks/permafrost_slush_top.png"),"hardness":0.9,"canHaverst":0,"drops":[{"id":199,"amount":1}],"name":"Top permafrost slush","type":"simple"},
	200:{"texture":preload("res://textures/blocks/permafrost_silver_ore.png"),"hardness":5.5,"canHaverst":3,"drops":[{"id":200,"amount":1}],"name":"Silver ore","type":"simple"},
	201:{"texture":preload("res://textures/blocks/permafrost_bricks.png"),"hardness":2.5,"canHaverst":1,"drops":[{"id":201,"amount":1}],"name":"Permafrost bricks","type":"simple"},
	202:{"texture":preload("res://textures/blocks/carved_permafrost_bricks.png"),"hardness":2.5,"canHaverst":1,"drops":[{"id":202,"amount":1}],"name":"Carved permafrost bricks","type":"simple"},
	203:{"texture":preload("res://textures/blocks/permafrost_fence.png"),"hardness":2.5,"canHaverst":1,"drops":[{"id":203,"amount":1}],"name":"Permafrost fence","type":"block"},
	204:{"texture":preload("res://textures/blocks/permafrost_platform_full.png"),"hardness":2,"canHaverst":1,"drops":[{"id":204,"amount":1}],"name":"Permafrost platform","type":"platform"},
	206:{"texture":preload("res://textures/blocks/frigid_spawner.png"),"hardness":6,"canHaverst":2,"drops":[],"name":"Frigid spawner","type":"spawner"},
	216:{"texture":preload("res://textures/blocks/upgrade_table.png"),"hardness":5,"canHaverst":3,"drops":[{"id":216,"amount":1}],"name":"Upgrade table","type":"simple"},
	217:{"texture":preload("res://textures/blocks/moss.png"),"hardness":0.1,"canHaverst":0,"drops":[{"id":217,"amount":1}],"name":"Moss","type":"foliage"},
	218:{"texture":preload("res://textures/items/blue_mud_flower.png"),"hardness":0.1,"canHaverst":0,"drops":[{"id":218,"amount":1}],"name":"Blue mud flower","can_place_on":[1,2,146,147,219],"type":"foliage"},
	219:{"texture":preload("res://textures/blocks/grassy_mud_stone.png"),"hardness":1.2,"canHaverst":1,"drops":[{"id":219,"amount":1}],"name":"Grassy mud stone","type":"simple"},
	220:{"texture":preload("res://textures/blocks/snow_flower.png"),"hardness":0.1,"canHaverst":0,"drops":[{"id":220,"amount":1}],"name":"Snow flower","can_place_on":[1,2,21,24],"type":"foliage"},
	221:{"texture":preload("res://textures/items/coffee_bean.png"),"hardness":0.1,"canHaverst":0,"drops":[{"id":221,"amount":1}],"name":"Coffee bean","can_place_on":[119,120],"type":"foliage"},
	241:{"texture":preload("res://textures/blocks/music_player.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":241,"amount":1}],"name":"Music player","type":"music_player"},
	242:{"texture":preload("res://textures/blocks/silver_spike_up.png"),"hardness":5,"canHaverst":3,"drops":[{"id":242,"amount":1}],"name":"Silver spike","type":"spike"},
	243:{"texture":preload("res://textures/blocks/timer_block.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":243,"amount":1}],"name":"Timer block","type":"timer_block"},
	244:{"texture":preload("res://textures/blocks/trinanium_crystal.png"),"hardness":5,"canHaverst":1,"drops":[{"id":244,"amount":1}],"name":"Trinanium crystal","type":"simple"},
	245:{"texture":preload("res://textures/blocks/gold_bricks.png"),"hardness":5,"canHaverst":3,"drops":[{"id":245,"amount":1}],"name":"Gold bricks","type":"simple"},
	246:{"texture":preload("res://textures/blocks/endgame_locator.png"),"hardness":5,"canHaverst":3,"drops":[{"id":246,"amount":1}],"name":"Endgame locator","type":"locator"},
	247:{"texture":preload("res://textures/blocks/white_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":247,"amount":1}],"name":"White wool","type":"simple"},
	248:{"texture":preload("res://textures/blocks/light_gray_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":248,"amount":1}],"name":"Light gray wool","type":"simple"},
	249:{"texture":preload("res://textures/blocks/gray_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":249,"amount":1}],"name":"Gray wool","type":"simple"},
	250:{"texture":preload("res://textures/blocks/black_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":250,"amount":1}],"name":"Black wool","type":"simple"},
	251:{"texture":preload("res://textures/blocks/red_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":251,"amount":1}],"name":"Red wool","type":"simple"},
	252:{"texture":preload("res://textures/blocks/orange_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":252,"amount":1}],"name":"Orange wool","type":"simple"},
	253:{"texture":preload("res://textures/blocks/yellow_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":253,"amount":1}],"name":"Yellow wool","type":"simple"},
	254:{"texture":preload("res://textures/blocks/yellow_green_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":254,"amount":1}],"name":"Yellow green wool","type":"simple"},
	255:{"texture":preload("res://textures/blocks/green_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":255,"amount":1}],"name":"Green wool","type":"simple"},
	256:{"texture":preload("res://textures/blocks/cyan_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":256,"amount":1}],"name":"Cyan wool","type":"simple"},
	257:{"texture":preload("res://textures/blocks/blue_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":257,"amount":1}],"name":"Blue wool","type":"simple"},
	258:{"texture":preload("res://textures/blocks/purple_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":258,"amount":1}],"name":"Purple wool","type":"simple"},
	259:{"texture":preload("res://textures/blocks/pink_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":259,"amount":1}],"name":"Pink wool","type":"simple"},
	260:{"texture":preload("res://textures/blocks/brown_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":260,"amount":1}],"name":"Brown wool","type":"simple"},
	261:{"texture":preload("res://textures/blocks/tan_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":261,"amount":1}],"name":"Tan wool","type":"simple"},
	262:{"texture":preload("res://textures/blocks/maroon_wool.png"),"hardness":0.4,"canHaverst":0,"drops":[{"id":262,"amount":1}],"name":"Maroon wool","type":"simple"},
	263:{"texture":preload("res://textures/blocks/wool_work_table.png"),"hardness":2,"canHaverst":1,"drops":[{"id":263,"amount":1}],"name":"Wool work table","type":"simple"},
	264:{"texture":preload("res://textures/blocks/cyan_led_lamp.png"),"hardness":0.75,"canHaverst":1,"drops":[{"id":264,"amount":1}],"name":"Cyan LED lamp","type":"simple","light_color":Color("50c2fc"),"light_intensity":8},
	265:{"texture":preload("res://textures/blocks/red_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":265,"amount":1}],"name":"Red LED lamp","type":"simple","light_color":Color("e34848"),"light_intensity":8},
	266:{"texture":preload("res://textures/blocks/orange_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":266,"amount":1}],"name":"Orange LED lamp","type":"simple","light_color":Color("ff9751"),"light_intensity":8},
	267:{"texture":preload("res://textures/blocks/yellow_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":267,"amount":1}],"name":"Yellow LED lamp","type":"simple","light_color":Color("ffdc61"),"light_intensity":8},
	268:{"texture":preload("res://textures/blocks/yellow_green_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":268,"amount":1}],"name":"Yellow green LED lamp","type":"simple","light_color":Color("b5c36a"),"light_intensity":8},
	269:{"texture":preload("res://textures/blocks/green_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":269,"amount":1}],"name":"Green LED lamp","type":"simple","light_color":Color("28c044"),"light_intensity":8},
	270:{"texture":preload("res://textures/blocks/blue_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":270,"amount":1}],"name":"Blue LED lamp","type":"simple","light_color":Color("5991f6"),"light_intensity":8},
	271:{"texture":preload("res://textures/blocks/purple_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":271,"amount":1}],"name":"Purple LED lamp","type":"simple","light_color":Color("9f5da7"),"light_intensity":8},
	272:{"texture":preload("res://textures/blocks/pink_led_lamp.png"),"hardness":0.75,"canHaverst":0,"drops":[{"id":272,"amount":1}],"name":"Pink LED lamp","type":"simple","light_color":Color("e08ac6"),"light_intensity":8},
	273:{"texture":preload("res://textures/blocks/quartz_bricks_1.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":273,"amount":1}],"name":"Quartz bricks","type":"block"},
	274:{"texture":preload("res://textures/blocks/rose_quartz_bricks_1.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":274,"amount":1}],"name":"Rose quartz bricks","type":"block"},
	275:{"texture":preload("res://textures/blocks/purple_quartz_bricks_1.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":275,"amount":1}],"name":"Purple quartz bricks","type":"block"},
	276:{"texture":preload("res://textures/blocks/blue_quartz_bricks_1.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":276,"amount":1}],"name":"Blue quartz bricks","type":"block"},
	277:{"texture":preload("res://textures/blocks/asteroid_rock_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":277,"amount":1}],"name":"Asteroid rock bricks","type":"simple"},
	278:{"texture":preload("res://textures/blocks/carved_asteroid_rock.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":278,"amount":1}],"name":"Carved asteroid rock","type":"simple"},
	279:{"texture":preload("res://textures/blocks/polished_asteroid_rock.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":279,"amount":1}],"name":"Polished asteroid rock","type":"simple"},
}

var itemData = {
	4:{"texture":preload("res://textures/items/wood_pick.png"),"type":"tool","strength":1,"speed":1,"big_texture":preload("res://textures/weapons/wood_pick.png"),"name":"Wood pickaxe","desc":"[color=cornflowerblue]+1 Strength\n+1 Speed[/color]","stack_size":1},
	5:{"texture":preload("res://textures/items/stick.png"),"type":"Item","name":"Stick"},
	31:{"texture":preload("res://textures/items/stone_pick.png"),"type":"tool","strength":2,"speed":2,"big_texture":preload("res://textures/weapons/stone_pick.png"),"name":"Stone pickaxe","desc":"[color=cornflowerblue]+2 Strength\n+2 Speed[/color]","stack_size":1},
	32:{"texture":preload("res://textures/items/armor/shirt.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"buff":[]},"name":"Shirt","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	33:{"texture":preload("res://textures/items/armor/jeans.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"buff":[]},"name":"Jeans","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	34:{"texture":preload("res://textures/items/armor/black_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"buff":[]},"name":"Black shoes","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	35:{"texture":preload("res://textures/items/armor/copper_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":1,"speed":0,"buff":[]},"name":"Copper helmet","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]","stack_size":1},
	36:{"texture":preload("res://textures/items/armor/copper_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":3,"speed":-1,"buff":[]},"name":"Copper chestplate","desc":"[color=cornflowerblue]+3 Def\n-1 Speed[/color]","stack_size":1},
	37:{"texture":preload("res://textures/items/armor/copper_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":2,"speed":-1,"buff":[]},"name":"Copper leggings","desc":"[color=cornflowerblue]+2 Def\n-1 Speed[/color]","stack_size":1},
	38:{"texture":preload("res://textures/items/armor/copper_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":1,"speed":0,"buff":[]},"name":"Copper boots","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]","stack_size":1},
	39:{"texture":preload("res://textures/items/armor/silver_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":2,"speed":0,"buff":[]},"name":"Silver helmet","desc":"[color=cornflowerblue]+2 Def\n+0 Speed[/color]","stack_size":1},
	40:{"texture":preload("res://textures/items/armor/silver_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":5,"speed":-2,"buff":[]},"name":"Silver chestplate","desc":"[color=cornflowerblue]+5 Def\n-2 Speed[/color]","stack_size":1},
	41:{"texture":preload("res://textures/items/armor/silver_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":3,"speed":-1,"buff":[]},"name":"Silver leggings","desc":"[color=cornflowerblue]+3 Def\n-1 Speed[/color]","stack_size":1},
	42:{"texture":preload("res://textures/items/armor/silver_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":2,"speed":0,"buff":[]},"name":"Silver boots","desc":"[color=cornflowerblue]+2 Def\n+0 Speed[/color]","stack_size":1},
	43:{"texture":preload("res://textures/items/armor/tuxedo.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"buff":[]},"name":"Tuxedo","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	44:{"texture":preload("res://textures/items/armor/slacks.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"buff":[]},"name":"Slacks","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	45:{"texture":preload("res://textures/items/armor/top_hat.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"buff":[]},"name":"Top hat","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	46:{"texture":preload("res://textures/items/armor/space_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"buff":[]},"name":"Space helmet","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]\n[color=darkorchid]Airtight[/color]","stack_size":1},
	47:{"texture":preload("res://textures/items/armor/space_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":1,"speed":-2,"buff":[]},"name":"Space chestplate","desc":"[color=cornflowerblue]+1 Def\n-2 Speed[/color]\n[color=darkorchid]Airtight[/color]","stack_size":1},
	48:{"texture":preload("res://textures/items/armor/space_pants.png"),"type":"armor","armor_data":{"armor_type":"pants","def":1,"speed":-1,"buff":[]},"name":"Space pants","desc":"[color=cornflowerblue]+1 Def\n-1 Speed[/color]\n[color=darkorchid]Airtight[/color]","stack_size":1},
	49:{"texture":preload("res://textures/items/armor/space_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"buff":[]},"name":"Space shoes","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]\n[color=darkorchid]Airtight[/color]","stack_size":1},
	50:{"texture":preload("res://textures/items/armor/red_dress.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"buff":[]},"name":"Red dress top","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	51:{"texture":preload("res://textures/items/armor/red_dress_bottom.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":-1,"buff":[]},"name":"Red dress bottom","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]","stack_size":1},
	52:{"texture":preload("res://textures/items/copper.png"),"type":"Item","name":"Copper"},
	53:{"texture":preload("res://textures/items/copper_pick.png"),"type":"tool","strength":3,"speed":4,"big_texture":preload("res://textures/weapons/copper_pick.png"),"name":"Copper pickaxe","desc":"[color=cornflowerblue]+3 Strength\n+4 Speed[/color]","stack_size":1},
	54:{"texture":preload("res://textures/items/stone_spear.png"),"type":"weapon","weapon_type":"Spear","dmg":3,"speed":2,"range":64,"big_texture":preload("res://textures/weapons/stone_spear.png"),"name":"Stone spear","desc":"[color=cornflowerblue]+3 Damage\n+2 Speed\n+4 Range[/color]","stack_size":1},
	56:{"texture":preload("res://textures/items/silver.png"),"type":"Item","name":"Silver"},
	57:{"texture":preload("res://textures/items/silver_pick.png"),"type":"tool","strength":4,"speed":6,"big_texture":preload("res://textures/weapons/silver_pick.png"),"name":"Silver pickaxe","desc":"[color=cornflowerblue]+4 Strength\n+6 Speed[/color]","stack_size":1},
	58:{"texture":preload("res://textures/items/wood_club.png"),"type":"weapon","weapon_type":"Club","dmg":3,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/wood_club.png"),"name":"Wood club","desc":"[color=cornflowerblue]+3 Damage\n+1 Speed\n+2 Range[/color]","stack_size":1},
	59:{"texture":preload("res://textures/items/wood_axe_big.png"),"type":"weapon","weapon_type":"Axe","dmg":4,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/wood_axe.png"),"name":"Wood axe","desc":"[color=cornflowerblue]+4 Damage\n+2 Speed\n+2 Range[/color]","stack_size":1},
	60:{"texture":preload("res://textures/items/wood_machete_big.png"),"type":"weapon","weapon_type":"Machete","dmg":1,"speed":0.1,"range":16,"big_texture":preload("res://textures/weapons/wood_machete.png"),"name":"Wood machete","desc":"[color=cornflowerblue]+1 Damage\n+0.1 Speed\n+1 Range[/color]","stack_size":1},
	61:{"texture":preload("res://textures/items/wood_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":2,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/wood_sword.png"),"name":"Wood sword","desc":"[color=cornflowerblue]+2 Damage\n+0.5 Speed\n+2 Range[/color]","stack_size":1},
	62:{"texture":preload("res://textures/items/barbed_club.png"),"type":"weapon","weapon_type":"Club","dmg":5,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/barbed_club.png"),"name":"Barbed club","desc":"[color=cornflowerblue]+5 Damage\n+1 Speed\n+2 Range[/color]","stack_size":1},
	63:{"texture":preload("res://textures/items/copper_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":7,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/copper_axe.png"),"name":"Copper axe","desc":"[color=cornflowerblue]+7 Damage\n+2 Speed\n+2 Range[/color]","stack_size":1},
	64:{"texture":preload("res://textures/items/copper_dagger.png"),"type":"weapon","weapon_type":"Dagger","dmg":2,"speed":0.1,"range":16,"big_texture":preload("res://textures/weapons/copper_dagger.png"),"name":"Copper dagger","desc":"[color=cornflowerblue]+2 Damage\n+0.1 Speed\n+1 Range[/color]","stack_size":1},
	65:{"texture":preload("res://textures/items/copper_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":4,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/copper_sword.png"),"name":"Copper sword","desc":"[color=cornflowerblue]+4 Damage\n+0.5 Speed\n+2 Range[/color]","stack_size":1},
	66:{"texture":preload("res://textures/items/silver_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":12,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/silver_axe.png"),"name":"Silver axe","desc":"[color=cornflowerblue]+12 Damage\n+2 Speed\n+2 Range[/color]","stack_size":1},
	67:{"texture":preload("res://textures/items/silver_dagger.png"),"type":"weapon","weapon_type":"Dagger","dmg":5,"speed":0.1,"range":16,"big_texture":preload("res://textures/weapons/silver_dagger.png"),"name":"Silver dagger","desc":"[color=cornflowerblue]+5 Damage\n+0.1 Speed\n+1 Range[/color]","stack_size":1},
	68:{"texture":preload("res://textures/items/silver_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":8,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/silver_sword.png"),"name":"Silver sword","desc":"[color=cornflowerblue]+8 Damage\n+0.5 Speed\n+2 Range[/color]","stack_size":1},
	74:{"texture":preload("res://textures/items/rhodonite.png"),"type":"Item","name":"Rhodonite"},
	92:{"texture":preload("res://textures/items/exotic_wood_pick.png"),"type":"tool","strength":1,"speed":2,"big_texture":preload("res://textures/weapons/exotic_wood_pick.png"),"name":"Exotic wood pickaxe","desc":"[color=cornflowerblue]+1 Strength\n+2 Speed[/color]","stack_size":1},
	93:{"texture":preload("res://textures/items/exotic_wood_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":3,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/exotic_wood_sword.png"),"name":"Exotic wood sword","desc":"[color=cornflowerblue]+3 Damage\n+0.5 Speed\n+2 Range[/color]","stack_size":1},
	94:{"texture":preload("res://textures/items/exotic_wood_club.png"),"type":"weapon","weapon_type":"Club","dmg":4,"speed":1,"range":32,"big_texture":preload("res://textures/items/exotic_wood_club.png"),"name":"Exotic wood club","desc":"[color=cornflowerblue]+4 Damage\n+1 Speed\n+2 Range[/color]","stack_size":1},
	95:{"texture":preload("res://textures/items/exotic_barbed_club.png"),"type":"weapon","weapon_type":"Club","dmg":5,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/exotic_barbed_club.png"),"name":"Exotic barbed club","desc":"[color=cornflowerblue]+5 Damage\n+1 Speed\n+2 Range[/color]","stack_size":1},
	96:{"texture":preload("res://textures/items/rhodonite_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":10,"speed":0.25,"range":32,"big_texture":preload("res://textures/weapons/rhodonite_sword.png"),"name":"Rhodonite sword","desc":"[color=cornflowerblue]+10 Damage\n+0.25 Speed\n+2 Range[/color]","stack_size":1},
	97:{"texture":preload("res://textures/items/rhodonite_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":16,"speed":3.5,"range":32,"big_texture":preload("res://textures/weapons/rhodonite_axe.png"),"name":"Rhodonite axe","desc":"[color=cornflowerblue]+16 Damage\n+3.5 Speed\n+2 Range[/color]","stack_size":1},
	98:{"texture":preload("res://textures/items/rhodonite_pick.png"),"type":"tool","strength":5,"speed":8,"big_texture":preload("res://textures/weapons/rhodonite_pick.png"),"name":"Rhodonite pickaxe","desc":"[color=cornflowerblue]+5 Strength\n+8 Speed[/color]","stack_size":1},
	99:{"texture":preload("res://textures/items/rhodonite_spear.png"),"type":"weapon","weapon_type":"Spear","dmg":8,"speed":1,"range":96,"big_texture":preload("res://textures/weapons/rhodonite_spear.png"),"name":"Rhodonite spear","desc":"[color=cornflowerblue]+8 Damage\n+1 Speed\n+6 Range[/color]","stack_size":1},
	100:{"texture":preload("res://textures/items/quartz.png"),"type":"Item","name":"Quartz"},
	101:{"texture":preload("res://textures/items/rose_quartz.png"),"type":"Item","name":"Rose quartz"},
	102:{"texture":preload("res://textures/items/purple_quartz.png"),"type":"Item","name":"Purple quartz"},
	103:{"texture":preload("res://textures/items/blue_quartz.png"),"type":"Item","name":"Blue quartz"},
	113:{"texture":preload("res://textures/items/silver_bucket_level_0.png"),"type":"Bucket","name":"Silver bucket","starter_data":{"water_level":0}},
	114:{"texture":preload("res://textures/items/copper_bucket_level_0.png"),"type":"Bucket","name":"Copper bucket","starter_data":{"water_level":0}},
	115:{"texture":preload("res://textures/items/silver_bucket_level_4.png"),"type":"Full_bucket","name":"Silver bucket of water","stack_size":1},
	116:{"texture":preload("res://textures/items/copper_bucket_level_4.png"),"type":"Full_bucket","name":"Copper bucket of water","stack_size":1},
	125:{"texture":preload("res://textures/items/wheat.png"),"type":"Item","name":"Wheat"},
	126:{"texture":preload("res://textures/items/tomato.png"),"type":"Food","name":"Tomato","regen":2,"desc":"[color=cornflowerblue]+2 HP[/color]"},
	127:{"texture":preload("res://textures/items/corn.png"),"type":"Food","name":"Corn","regen":4,"desc":"[color=cornflowerblue]+4 HP[/color]"},
	129:{"texture":preload("res://textures/items/stone_hoe.png"),"type":"Hoe","name":"Stone hoe","big_texture":preload("res://textures/weapons/stone_hoe.png"),"stack_size":1},
	130:{"texture":preload("res://textures/items/silver_hoe.png"),"type":"Hoe","name":"Silver hoe","big_texture":preload("res://textures/weapons/silver_hoe.png"),"stack_size":1},
	131:{"texture":preload("res://textures/items/copper_watering_can.png"),"type":"Watering_can","name":"Copper watering can","big_texture":preload("res://textures/weapons/copper_watering_can.png"),"stack_size":1,"starter_data":{"water_level":0}},
	132:{"texture":preload("res://textures/items/silver_watering_can.png"),"type":"Watering_can","name":"Silver watering can","big_texture":preload("res://textures/weapons/silver_watering_can.png"),"stack_size":1,"starter_data":{"water_level":0}},
	140:{"texture":preload("res://textures/items/bread.png"),"type":"Food","name":"Bread","regen":8,"desc":"[color=cornflowerblue]+8 HP[/color]"},
	165:{"texture":preload("res://textures/items/iron.png"),"type":"Item","name":"Iron"},
	166:{"texture":preload("res://textures/items/red_wires.png"),"type":"wire","name":"Red wire"},
	191:{"texture":preload("res://textures/items/magma_ball.png"),"type":"Item","name":"Magma ball"},
	193:{"texture":preload("res://textures/items/gold.png"),"type":"Item","name":"Gold"},
	205:{"texture":preload("res://textures/items/coolant_shard.png"),"type":"Item","name":"Coolant shard"},
	207:{"texture":preload("res://textures/items/armor/coat_hood.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"buff":[]},"name":"Coat hood","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]\n[color=darkorchid]Cold resistance[/color]","stack_size":1},
	208:{"texture":preload("res://textures/items/armor/coat.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":1,"speed":0,"buff":[]},"name":"Coat","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]\n[color=darkorchid]Cold resistance[/color]","stack_size":1},
	209:{"texture":preload("res://textures/items/armor/coat_pants.png"),"type":"armor","armor_data":{"armor_type":"pants","def":1,"speed":0,"buff":[]},"name":"Coat pants","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]\n[color=darkorchid]Cold resistance[/color]","stack_size":1},
	210:{"texture":preload("res://textures/items/armor/coat_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"buff":[]},"name":"Coat boots","desc":"[color=cornflowerblue]+0 Def\n+0 Speed[/color]\n[color=darkorchid]Cold resistance[/color]","stack_size":1},
	211:{"texture":preload("res://textures/items/armor/fire_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":1,"speed":0,"buff":[]},"name":"Fire helmet","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]\n[color=darkorchid]Heat resistance[/color]","stack_size":1},
	212:{"texture":preload("res://textures/items/armor/fire_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":3,"speed":-1,"buff":[]},"name":"Fire chestplate","desc":"[color=cornflowerblue]+3 Def\n-1 Speed[/color]\n[color=darkorchid]Heat resistance[/color]","stack_size":1},
	213:{"texture":preload("res://textures/items/armor/fire_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":2,"speed":-1,"buff":[]},"name":"Fire leggings","desc":"[color=cornflowerblue]+2 Def\n-1 Speed[/color]\n[color=darkorchid]Heat resistance[/color]","stack_size":1},
	214:{"texture":preload("res://textures/items/armor/fire_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":1,"speed":0,"buff":[]},"name":"Fire boots","desc":"[color=cornflowerblue]+1 Def\n+0 Speed[/color]\n[color=darkorchid]Heat resistance[/color]","stack_size":1},
	215:{"texture":preload("res://textures/items/upgrade_module.png"),"type":"Item","name":"Upgrade module","stack_size":1,"starter_data":{"upgrade":"none"}},
	222:{"texture":preload("res://textures/items/red_dye.png"),"type":"Item","name":"Red dye"},
	223:{"texture":preload("res://textures/items/orange_dye.png"),"type":"Item","name":"Orange dye"},
	224:{"texture":preload("res://textures/items/yellow_dye.png"),"type":"Item","name":"Yellow dye"},
	225:{"texture":preload("res://textures/items/yellow_green_dye.png"),"type":"Item","name":"Yellow green dye"},
	226:{"texture":preload("res://textures/items/green_dye.png"),"type":"Item","name":"Green dye"},
	227:{"texture":preload("res://textures/items/cyan_dye.png"),"type":"Item","name":"Cyan dye"},
	228:{"texture":preload("res://textures/items/blue_dye.png"),"type":"Item","name":"Blue dye"},
	229:{"texture":preload("res://textures/items/purple_dye.png"),"type":"Item","name":"Purple dye"},
	230:{"texture":preload("res://textures/items/pink_dye.png"),"type":"Item","name":"Pink dye"},
	231:{"texture":preload("res://textures/items/maroon_dye.png"),"type":"Item","name":"Maroon dye"},
	232:{"texture":preload("res://textures/items/brown_dye.png"),"type":"Item","name":"Brown dye"},
	233:{"texture":preload("res://textures/items/tan_dye.png"),"type":"Item","name":"Tan dye"},
	234:{"texture":preload("res://textures/items/white_dye.png"),"type":"Item","name":"White dye"},
	235:{"texture":preload("res://textures/items/light_gray_dye.png"),"type":"Item","name":"Light gray dye"},
	236:{"texture":preload("res://textures/items/gray_dye.png"),"type":"Item","name":"Gray dye"},
	237:{"texture":preload("res://textures/items/black_dye.png"),"type":"Item","name":"Black dye"},
	238:{"texture":preload("res://textures/items/music_chip_alpha_andromedae.png"),"type":"Item","name":"Music chip - Alpha Andromedae","stack_size":1},
	239:{"texture":preload("res://textures/items/music_chip_past.png"),"type":"Item","name":"Music chip - Past","stack_size":1},
	240:{"texture":preload("res://textures/items/music_chip_tinkering_machine.png"),"type":"Item","name":"Music chip - Tinkering Machine","stack_size":1},
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
	var _er = StarSystem.connect("planet_ready", start_world)
	_er = Global.connect("loaded_data", start_world)
	get_tree().paused = false
	if Global.gameStart:
		StarSystem.start_game()

func start_world():
	print("World started")
	if !StarSystem.planetReady:
		await StarSystem.planet_ready
	#world size stuff
	match Global.gamerules["custom_generation"]:
		"meteor":
			worldSize = Vector2(256,32)
		"":
			worldSize = StarSystem.get_current_world_size()
	$"../LightingViewport/SubViewport/LightRect".material.set_shader_parameter("world_size",worldSize)
	lightMap = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGBA8)
	lightIntensityMap = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGBA8)
	lightMap.fill(Color.WHITE)
	lightIntensityMap.fill(Color("FF000005"))
	$StaticBody2D/Right.position = Vector2(worldSize.x * BLOCK_SIZE.x + 2,(worldSize.y * BLOCK_SIZE.y) / 2)
	$StaticBody2D/Right.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$"../Player/PlayerCamera".limit_right = worldSize.x * BLOCK_SIZE.x -4
	$"../Player/PlayerCamera".limit_bottom = worldSize.y * BLOCK_SIZE.y + 24
	$StaticBody2D/Left.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$StaticBody2D/Left.position.y = (worldSize.y * BLOCK_SIZE.y) / 2 - 8
	$StaticBody2D/Bottom.shape.extents.y = (worldSize.x * BLOCK_SIZE.x) / 2
	$StaticBody2D/Bottom.position = Vector2((worldSize.x * BLOCK_SIZE.x) / 2,worldSize.y * BLOCK_SIZE.y)
	var currentPlanetData = StarSystem.find_planet_id(Global.currentPlanet)
	worldType = currentPlanetData.type["type"]
	get_node("../CanvasLayer/Black").show()
	if !currentPlanetData.hasAtmosphere:
		get_node("../CanvasLayer/ParallaxBackground/SkyLayer").hide()
	if worldType == "asteroids":
		hasGravity = false
	if !Global.gameStart:
		Global.playerData.erase("pos")
	if Global.inTutorial:
		player.gender = "Guy"
		armor.armor = {"Helmet":{},"Hat":{},"Chestplate":{"id":32,"amount":1,"data":{}},"Shirt":{},"Leggings":{"id":33,"amount":1,"data":{}},"Pants":{},"Boots":{"id":34,"amount":1,"data":{}},"Shoes":{}}
		armor.emit_signal("updated_armor",armor.armor)
	elif !(Global.gameStart and Global.new):
		load_player_data()
	if Global.new or Global.load_planet(Global.currentSystemId,Global.currentPlanet).is_empty(): #This is if this is a new planet
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
	enviroment.set_background(worldType)
	emit_signal("world_loaded")
	get_node("../CanvasLayer/ParallaxBackground2/Sky").init_sky()
	worldLoaded = true
	get_node("../CanvasLayer/Black/AnimationPlayer").play("fadeOut")
	await get_tree().process_frame
	update_light_texture()
	emit_signal("update_blocks")
	Global.gameStart = false
	inventory.update_inventory()
	Global.save("planet",get_world_data())

func generateWorld(worldType : String):
	var worldSeed = int(Global.currentSystemId) + Global.currentPlanet
	var currentPlanetData = StarSystem.find_planet_id(Global.currentPlanet)
	seed(worldSeed)
	worldNoise = generationData[worldType]["noise"]
	worldNoise.seed = worldSeed
	caveNoise.seed = worldSeed
	noiseScale = generationData[worldType]["noise_scale"]
	worldHeight = generationData[worldType]["world_height"]
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
		"misc_stats":{"meteor_stage":meteors.stage,"meteor_progress_time_left":$"../CanvasLayer/Enviroment/Meteors/StageProgress".time_left}
	}
	data["system"] = StarSystem.get_system_data()
	data["planet"] = {"blocks":get_blocks_data(),"entities":entities.get_entity_data(),"rules":worldRules,"left_at_time":Global.globalGameTime,"current_weather":$"..".currentWeather,"weather_time_left":$"../weather/WeatherTimer".time_left,"wires":[]}
	for wire in $Wires.get_children():
		data["planet"]["wires"].append({"output_block_pos":wire.outputBlock.pos,"output_block_layer":wire.outputBlock.layer,"output_pin":wire.outputPin,"input_block_pos":wire.inputBlock.pos,"input_block_layer":wire.inputBlock.layer,"input_pin":wire.inputPin})
	return data

func get_blocks_data(withinArea : bool = false,area : Rect2 = Rect2()) -> Array:
	var blocks = []
	for block in $blocks.get_children():
		if (blockData[block.id]["type"] != "door" or block.mainBlock == block) and (!withinArea or area.has_point(block.pos)):
			if block.id == 186:
				print(block.data)
			blocks.append({"id":block.id,"layer":block.layer,"position":block.pos if !withinArea else block.pos - area.position ,"data":block.data})
	return blocks

func get_structure_blocks(area : Rect2) -> Dictionary:
	var blocks = {"blocks":[],"link_blocks":[]}
	for block in $blocks.get_children():
		if (blockData[block.id]["type"] != "door" or block.mainBlock == block) and area.has_point(block.pos):
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
	Global.playerBase = {"skin":playerData["skin"],"hair_style":playerData["hair_style"],"hair_color":playerData["hair_color"],"sex":playerData["sex"]}
	player.get_node("Textures/body").modulate = playerData["skin"]
	player.gender = playerData["sex"]
	player.health = playerData["health"]
	player.oxygen = playerData["oxygen"]
	player.suitOxygen = playerData["suit_oxygen"]
	player.maxHealth = playerData["max_health"]
	player.maxOxygen = playerData["max_oxygen"]
	player.suitOxygenMax = playerData["suit_oxygen_max"]
	var inventorySet : Array = playerData["inventory"]
	if playerData["version"][1] < 5: #adds item data to every item in the inventory if before TU5
		for item : Dictionary in inventorySet:
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
		return itemData[item_id]["texture"]
	return null

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

func set_block(pos : Vector2, layer : int, id : int, update = false, data = {}) -> void:
	var blockAtPos = get_block(pos,layer)
	if blockAtPos != null or (id == 0 and blockAtPos != null):
		$blocks.remove_child(blockAtPos)
		if blockData[blockAtPos.id]["type"] == "door":
			blockAtPos.emit_signal("destroyed")
		blockAtPos.queue_free()
		if id == 0:
			match layer:
				0:
					if transparentBlocks.has(get_block_id(pos,1)) and pos.y >= generationData[worldType]["world_height"] + generationData[worldType]["noise_scale"]:
						set_light(pos,Color.WHITE,Color("FF000005"),update)
				1:
					if transparentBlocks.has(get_block_id(pos,0)) and pos.y >= generationData[worldType]["world_height"] + generationData[worldType]["noise_scale"]:
						set_light(pos,Color.WHITE,Color("FF000005"),update)
					else:
						set_light(pos,Color("00000000"),Color("00000000"),update)
	if id > 0:
		var block = blockTypes[blockData[id]["type"]].instantiate()
		var block_data = get_item_data(id)
		match layer:
			0:
				if transparentBlocks.has(get_block_id(pos,1)):
					if block_data.has("light_color"):
						set_light(pos,block_data["light_color"],Color("0" + str(block_data["light_intensity"]) + "000005"),update)
					elif !transparentBlocks.has(id) or pos.y >= generationData[worldType]["world_height"] + generationData[worldType]["noise_scale"]:
						set_light(pos,Color("00000000"),Color("00000000"),update)
			1:
				if !transparentBlocks.has(id):
					if block_data.has("light_color"):
						set_light(pos,block_data["light_color"],Color("0" + str(block_data["light_intensity"]) + "0000FF"),update)
					else:
						set_light(pos,Color.BLACK,Color.BLACK,update)
				elif block_data.has("light_color"):
					set_light(pos,block_data["light_color"],Color("0" + str(block_data["light_intensity"]) + "000005"),update)
		block.position = pos * BLOCK_SIZE
		block.pos = pos
		block.id = id
		block.layer = layer
		block.data = data
		block.name = str(pos.x) + "," + str(pos.y) + "," + str(layer)
		if block.has_node("Sprite2D"):
			block.get_node("Sprite2D").texture = get_item_texture(id)
		$blocks.add_child(block)
		if blockData[id]["type"] == "door": #adds ghost blocks for door
			for y in [-1,1]:
				var newBlockAtPos = get_block(pos + Vector2(0,y),layer)
				if newBlockAtPos != null:
					$blocks.remove_child(newBlockAtPos)
					if blockData[newBlockAtPos.id]["type"] == "door":
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
	$"../LightingViewport/SubViewport/LightRect".material.set_shader_parameter("light_map",ImageTexture.create_from_image(lightMap))
	$"../LightingViewport/SubViewport/LightRect".material.set_shader_parameter("light_intensity_map",ImageTexture.create_from_image(lightIntensityMap))

func build_event(action : String, pos : Vector2, layer : int,id = 0, itemAction = true) -> void:
	if action == "Build" and [0,6,7,117].has(get_block_id(pos,layer)) and blockData.has(id) and (!blockData[id].has("can_place_on") or blockData[id]["can_place_on"].has(get_block_id(pos + Vector2(0,1),layer))):
		var canPlace = true
		if blockData[id]["type"] == "door": #Makes sure all blocks are clear for the door
			if [0,6,7,117].has(get_block_id(pos + Vector2(0,2),layer)):
				canPlace = false
			for y in [-1,1]:
				if ![0,6,7,117].has(get_block_id(pos + Vector2(0,y),layer)):
					canPlace = false
		if canPlace:
			set_block(pos,layer,id,true)
			if itemAction:
				inventory.remove_id_from_inventory(id,1)
	elif action == "Break" and get_block(pos,layer) != null:
		var block = get_block(pos,layer).id
		match block:
			91:
				for item in get_block(pos,layer).data:
					entities.spawn_item({"id":item["id"],"amount":item["amount"],"data":item["data"]},false,pos*BLOCK_SIZE)
		if itemAction and !Global.godmode:
			var itemsToDrop = blockData[block]["drops"]
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
