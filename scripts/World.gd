extends Node2D

const BLOCK = preload("res://assets/Block.tscn")
const SIMPLE_BLOCK = preload("res://assets/blocks/SimpleBlock.tscn")
const BLOCK_SIZE = Vector2(8,8)

export var worldSize = Vector2(16,24)
export var worldNoise : OpenSimplexNoise
export var asteroidNoise : OpenSimplexNoise
export var oceanNoise : OpenSimplexNoise
export var noiseScale = 15
export var worldHeight = 20

onready var inventory = $"../CanvasLayer/Inventory"
onready var enviroment = $"../CanvasLayer/Enviroment"
onready var armor = $"../CanvasLayer/Inventory/Armor"
onready var player = $"../Player"
onready var entities = $"../Entities"
onready var meteors = $"../CanvasLayer/Enviroment/Meteors"

var shops = {
	"lily_mart":preload("res://assets/shops/LilyMart.tscn"),
	"skips_stones":preload("res://assets/shops/SkipsStones.tscn")
}

var currentPlanet : Object

var worldLoaded = false
var hasGravity = true

var waterUpdateList = []

var interactableBlocks = [12,16,28,91]

var transparentBlocks = [0,1,6,7,9,11,12,20,24,10,28,30,69,76,79,80,81,85,91,117,119,120,121,122,123]

var worldRules = {
	"break_blocks":{"value":true,"type":"bool"},
	"place_blocks":{"value":true,"type":"bool"},
	"interact_with_blocks":{"value":true,"type":"bool"},
	"entity_spawning":{"value":true,"type":"bool"},
	"enemy_spawning":{"value":true,"type":"bool"},
	"world_spawn_x":{"value":-1,"type":"int"},
	"world_spawn_y":{"value":-1,"type":"int"}
}

var blockData = {
	1:{"texture":preload("res://textures/blocks2X/grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":1,"amount":1}],"name":"Grass block","type":"block"},
	2:{"texture":preload("res://textures/blocks2X/dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Dirt","type":"simple"},
	3:{"texture":preload("res://textures/blocks2X/stone.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Stone","type":"simple"},
	6:{"texture":preload("res://textures/blocks2X/flower1.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Flower 1","can_place_on":[1,2],"type":"block"},
	7:{"texture":preload("res://textures/blocks2X/flower2.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Flower 2","can_place_on":[1,2],"type":"block"},
	8:{"texture":preload("res://textures/blocks2X/Cobble.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Cobble","type":"simple"},
	9:{"texture":preload("res://textures/blocks/tree_small.png"),"hardness":7,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":[3,6]},{"id":11,"amount":[0,3]}],"name":"Tree","type":"block"},
	10:{"texture":preload("res://textures/blocks2X/log_front.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":1}],"name":"Log","type":"block"},
	11:{"texture":preload("res://textures/items/pinecone.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":11,"amount":1}],"name":"Pinecone","can_place_on":[1,2],"type":"block"},
	12:{"texture":preload("res://textures/blocks2X/crafting_table.png"),"hardness":2,"breakWith":"Axe","canHaverst":1,"drops":[{"id":12,"amount":1}],"name":"Workbench","type":"simple"},
	13:{"texture":preload("res://textures/blocks2X/planks.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":13,"amount":1}],"name":"Planks","type":"simple"},
	14:{"texture":preload("res://textures/blocks2X/sand.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":14,"amount":1}],"name":"Sand","type":"block"},
	15:{"texture":preload("res://textures/blocks2X/stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":15,"amount":1}],"name":"Stone bricks","type":"simple"},
	16:{"texture":preload("res://textures/blocks2X/oven.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":16,"amount":1}],"name":"Oven","type":"simple"},
	17:{"texture":preload("res://textures/blocks2X/mud_stone.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":17,"amount":1}],"name":"Mud stone","type":"simple"},
	18:{"texture":preload("res://textures/blocks2X/mud_stone_dust.png"),"hardness":0.5,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":18,"amount":1}],"name":"Mud stone dust","type":"block"},
	19:{"texture":preload("res://textures/blocks2X/mud_stone_bricks.png"),"hardness":1.4,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":19,"amount":1}],"name":"Mud stone bricks","type":"simple"},
	20:{"texture":preload("res://textures/blocks2X/glass_icon.png"),"hardness":0.1,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":20,"amount":1}],"name":"Glass","type":"block"},
	21:{"texture":preload("res://textures/blocks2X/snow_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":21,"amount":1}],"name":"Snow block","type":"simple"},
	22:{"texture":preload("res://textures/blocks2X/sandstone.png"),"hardness":1.3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":22,"amount":1}],"name":"Sandstone","type":"simple"},
	23:{"texture":preload("res://textures/blocks2X/sandstone_bricks.png"),"hardness":2.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":23,"amount":1}],"name":"Sandstone bricks","type":"simple"},
	24:{"texture":preload("res://textures/blocks2X/grass_snow.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":24,"amount":1}],"name":"Grass snow","type":"block"},
	25:{"texture":preload("res://textures/blocks2X/clay.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":25,"amount":1}],"name":"Clay","type":"simple"},
	26:{"texture":preload("res://textures/blocks2X/bricks.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":26,"amount":1}],"name":"Bricks","type":"simple"},
	27:{"texture":preload("res://textures/blocks2X/brick_shingles.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":27,"amount":1}],"name":"Brick shingles","type":"simple"},
	28:{"texture":preload("res://textures/blocks2X/smithing_table.png"),"hardness":2.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":28,"amount":1}],"name":"Smithing table","type":"simple"},
	29:{"texture":preload("res://textures/blocks2X/copper_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":29,"amount":1}],"name":"Copper ore","type":"simple"},
	30:{"texture":preload("res://textures/blocks2X/platform_full.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":30,"amount":1}],"name":"Wood platform","type":"block"},
	55:{"texture":preload("res://textures/blocks2X/silver_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":55,"amount":1}],"name":"Silver ore","type":"simple"},
	69:{"texture":preload("res://textures/blocks2X/exotic_grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":69,"amount":1}],"name":"Exotic grass block","type":"simple"},
	70:{"texture":preload("res://textures/blocks2X/exotic_dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":70,"amount":1}],"name":"Exotic dirt","type":"simple"},
	71:{"texture":preload("res://textures/blocks2X/exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":71,"amount":1}],"name":"Exotic stone","type":"simple"},
	72:{"texture":preload("res://textures/blocks2X/exotic_stone_bricks.png"),"hardness":3.5,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":72,"amount":1}],"name":"Exotic stone bricks","type":"simple"},
	73:{"texture":preload("res://textures/blocks2X/rhodonite_ore.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":74,"amount":1}],"name":"Rhodonite ore","type":"simple"},
	75:{"texture":preload("res://textures/blocks2X/carved_exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":75,"amount":1}],"name":"Carved exotic stone","type":"simple"},
	76:{"texture":preload("res://textures/blocks2X/exotic_sapling.png"),"hardness":9,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":[3,6]},{"id":85,"amount":[0,3]}],"name":"Exotic tree","type":"block"},
	77:{"texture":preload("res://textures/blocks2X/exotic_log_front.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":1}],"name":"Exotic log","type":"block"},
	78:{"texture":preload("res://textures/blocks2X/exotic_planks.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":78,"amount":1}],"name":"Exotic planks","type":"simple"},
	79:{"texture":preload("res://textures/blocks2X/exotic_wood_window.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":79,"amount":1}],"name":"Exotic wood window","type":"block"},
	80:{"texture":preload("res://textures/blocks2X/wood_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":80,"amount":1}],"name":"Wood window","type":"block"},
	81:{"texture":preload("res://textures/blocks2X/copper_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":81,"amount":1}],"name":"Copper window","type":"block"},
	82:{"texture":preload("res://textures/blocks2X/mossy_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":82,"amount":1}],"name":"Mossy stone bricks","type":"simple"},
	83:{"texture":preload("res://textures/blocks2X/cracked_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":83,"amount":1}],"name":"Cracked stone bricks","type":"simple"},
	84:{"texture":preload("res://textures/blocks2X/mossy_cobblestone.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":84,"amount":1}],"name":"Mossy cobble","type":"simple"},
	85:{"texture":preload("res://textures/blocks2X/exotic_sapling.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":85,"amount":1}],"name":"Exotic sapling","can_place_on":[69,70],"type":"block"},
	86:{"texture":preload("res://textures/blocks2X/cracked_mud_bricks.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":86,"amount":1}],"name":"Cracked mud bricks","type":"simple"},
	87:{"texture":preload("res://textures/blocks2X/cracked_sandstone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":87,"amount":1}],"name":"Cracked sandstone bricks","type":"simple"},
	88:{"texture":preload("res://textures/blocks2X/copper_block.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":88,"amount":1}],"name":"Copper block","type":"simple"},
	89:{"texture":preload("res://textures/blocks2X/silver_block.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":89,"amount":1}],"name":"Silver block","type":"simple"},
	90:{"texture":preload("res://textures/blocks2X/rhodonite_block.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":90,"amount":1}],"name":"Rhodonite block","type":"simple"},
	91:{"texture":preload("res://textures/blocks2X/chest.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":91,"amount":1}],"name":"Chest","type":"block"},
	104:{"texture":preload("res://textures/blocks2X/quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":100,"amount":[1,3]}],"name":"Quartz ore","type":"simple"},
	105:{"texture":preload("res://textures/blocks2X/rose_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":101,"amount":[1,3]}],"name":"Rose quartz ore","type":"simple"},
	106:{"texture":preload("res://textures/blocks2X/purple_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":102,"amount":[1,3]}],"name":"Purple quartz ore","type":"simple"},
	107:{"texture":preload("res://textures/blocks2X/blue_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":103,"amount":[1,3]}],"name":"Blue quartz ore","type":"simple"},
	108:{"texture":preload("res://textures/blocks2X/quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":108,"amount":1}],"name":"Quartz block","type":"simple"},
	109:{"texture":preload("res://textures/blocks2X/rose_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":109,"amount":1}],"name":"Rose quartz block","type":"simple"},
	110:{"texture":preload("res://textures/blocks2X/purple_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":110,"amount":1}],"name":"Purple quartz block","type":"simple"},
	111:{"texture":preload("res://textures/blocks2X/blue_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":111,"amount":1}],"name":"Blue quartz block","type":"simple"},
	112:{"texture":preload("res://textures/blocks2X/asteroid_rock.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":112,"amount":1}],"name":"Asteroid rock","type":"simple"},
	117:{"texture":preload("res://textures/blocks2X/water/water_4.png"),"hardness":0,"breakWith":"None","canHaverst":0,"drops":[],"name":"Water","type":"block"},
	118:{"texture":preload("res://textures/blocks2X/wet_sand.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":118,"amount":1}],"name":"Wet sand","type":"simple"},
	119:{"texture":preload("res://textures/blocks2X/farmland_dry.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Farmland","type":"block"},
	120:{"texture":preload("res://textures/blocks2X/farmland_wet.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Wet farmland","type":"simple"},
	121:{"texture":preload("res://textures/items/wheat_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":121,"amount":1}],"name":"Wheat seeds","can_place_on":[119,120],"type":"block"},
	122:{"texture":preload("res://textures/items/tomato_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":122,"amount":1}],"name":"Tomato seeds","can_place_on":[119,120],"type":"block"},
	123:{"texture":preload("res://textures/items/corn_seeds.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":123,"amount":1}],"name":"Corn seeds","can_place_on":[119,120],"type":"block"},
	124:{"texture":preload("res://textures/blocks2X/rhodonite_ore_stone.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":74,"amount":1}],"name":"Rhodonite stone ore","type":"simple"},
	128:{"texture":preload("res://textures/items/fig_tree.png"),"hardness":0.1,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":121,"amount":[0,1]},{"id":122,"amount":[0,1]},{"id":123,"amount":[0,1]}],"name":"Fig tree","can_place_on":[1,2],"type":"block"},
	133:{"texture":preload("res://textures/blocks2X/copper_plate.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":133,"amount":1}],"name":"Copper plate","type":"simple"},
	134:{"texture":preload("res://textures/blocks2X/copper_bricks.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":134,"amount":1}],"name":"Copper bricks","type":"simple"},
	135:{"texture":preload("res://textures/blocks2X/cracked_copper_bricks.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":135,"amount":1}],"name":"Cracked copper bricks","type":"simple"},
	136:{"texture":preload("res://textures/blocks2X/silver_plate.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":136,"amount":1}],"name":"Silver plate","type":"simple"},
	137:{"texture":preload("res://textures/blocks2X/silver_bricks.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":137,"amount":1}],"name":"Silver bricks","type":"simple"},
	138:{"texture":preload("res://textures/blocks2X/cracked_silver_bricks.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":138,"amount":1}],"name":"Silver bricks","type":"simple"},
	139:{"texture":preload("res://textures/blocks2X/lily_mart.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Lily Mart","type":"shop","shop_type":"lily_mart"},
	141:{"texture":preload("res://textures/blocks2X/skips_stones.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Skip's stones","type":"shop","shop_type":"skips_stones"},
	142:{"texture":preload("res://textures/blocks2X/posters/poster_icon.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":142,"amount":1}],"name":"Poster 1","type":"block"},
	143:{"texture":preload("res://textures/blocks2X/posters/poster_icon.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":143,"amount":1}],"name":"Poster 2","type":"block"},
	144:{"texture":preload("res://textures/blocks2X/bottom_rock.png"),"hardness":0,"breakWith":"Pickaxe","canHaverst":100,"drops":[{"id":144,"amount":1}],"name":"Bottom rock","type":"simple"},
}

var itemData = {
	4:{"texture_loc":preload("res://textures/items/wood_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":1,"speed":1,"big_texture":preload("res://textures/weapons/wood_pick.png"),"name":"Wood pickaxe","desc":"+1 Strength\n+1 Speed"},
	5:{"texture_loc":preload("res://textures/items/stick.png"),"type":"Item","name":"Stick"},
	31:{"texture_loc":preload("res://textures/items/stone_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":2,"speed":2,"big_texture":preload("res://textures/weapons/stone_pick.png"),"name":"Stone pickaxe","desc":"+2 Strength\n+2 Speed"},
	32:{"texture_loc":preload("res://textures/items/armor/shirt.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false},"name":"Shirt","desc":"+0 Def\n+0 Speed"},
	33:{"texture_loc":preload("res://textures/items/armor/jeans.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"air_tight":false},"name":"Jeans","desc":"+0 Def\n+0 Speed"},
	34:{"texture_loc":preload("res://textures/items/armor/black_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"air_tight":false},"name":"Black shoes","desc":"+0 Def\n+0 Speed"},
	35:{"texture_loc":preload("res://textures/items/armor/copper_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":1,"speed":0,"air_tight":false},"name":"Copper helmet","desc":"+1 Def\n+0 Speed"},
	36:{"texture_loc":preload("res://textures/items/armor/copper_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":3,"speed":-1,"air_tight":false},"name":"Copper chestplate","desc":"+3 Def\n-1 Speed"},
	37:{"texture_loc":preload("res://textures/items/armor/copper_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":2,"speed":-1,"air_tight":false},"name":"Copper leggings","desc":"+2 Def\n-1 Speed"},
	38:{"texture_loc":preload("res://textures/items/armor/copper_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":1,"speed":0,"air_tight":false},"name":"Copper boots","desc":"+1 Def\n+0 Speed"},
	39:{"texture_loc":preload("res://textures/items/armor/silver_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":2,"speed":0,"air_tight":false},"name":"Silver helmet","desc":"+2 Def\n+0 Speed"},
	40:{"texture_loc":preload("res://textures/items/armor/silver_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":5,"speed":-2,"air_tight":false},"name":"Silver chestplate","desc":"+5 Def\n-2 Speed"},
	41:{"texture_loc":preload("res://textures/items/armor/silver_leggings.png"),"type":"armor","armor_data":{"armor_type":"pants","def":3,"speed":-1,"air_tight":false},"name":"Silver leggings","desc":"+3 Def\n-1 Speed"},
	42:{"texture_loc":preload("res://textures/items/armor/silver_boots.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":2,"speed":0,"air_tight":false},"name":"Silver boots","desc":"+2 Def\n+0 Speed"},
	43:{"texture_loc":preload("res://textures/items/armor/tuxedo.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false},"name":"Tuxedo","desc":"+0 Def\n+0 Speed"},
	44:{"texture_loc":preload("res://textures/items/armor/slacks.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":0,"air_tight":false},"name":"Slacks","desc":"+0 Def\n+0 Speed"},
	45:{"texture_loc":preload("res://textures/items/armor/top_hat.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"air_tight":false},"name":"Top hat","desc":"+0 Def\n+0 Speed"},
	46:{"texture_loc":preload("res://textures/items/armor/space_helmet.png"),"type":"armor","armor_data":{"armor_type":"helmet","def":0,"speed":0,"air_tight":true},"name":"Space helmet","desc":"+0 Def\n+0 Speed\nAirtight"},
	47:{"texture_loc":preload("res://textures/items/armor/space_chestplate.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":1,"speed":-2,"air_tight":true},"name":"Space chestplate","desc":"+1 Def\n-2 Speed\nAirtight"},
	48:{"texture_loc":preload("res://textures/items/armor/space_pants.png"),"type":"armor","armor_data":{"armor_type":"pants","def":1,"speed":-1,"air_tight":true},"name":"Space pants","desc":"+1 Def\n-1 Speed\nAirtight"},
	49:{"texture_loc":preload("res://textures/items/armor/space_shoes.png"),"type":"armor","armor_data":{"armor_type":"shoes","def":0,"speed":0,"air_tight":true},"name":"Space_shoes","desc":"+0 Def\n+0 Speed\nAirtight"},
	50:{"texture_loc":preload("res://textures/items/armor/red_dress.png"),"type":"armor","armor_data":{"armor_type":"shirt","def":0,"speed":0,"air_tight":false},"name":"Red dress top","desc":"+0 Def\n+0 Speed"},
	51:{"texture_loc":preload("res://textures/items/armor/red_dress_bottom.png"),"type":"armor","armor_data":{"armor_type":"pants","def":0,"speed":-1,"air_tight":false},"name":"Red dress bottom","desc":"+0 Def\n+0 Speed"},
	52:{"texture_loc":preload("res://textures/items/copper.png"),"type":"Item","name":"Copper"},
	53:{"texture_loc":preload("res://textures/items/copper_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":3,"speed":4,"big_texture":preload("res://textures/weapons/copper_pick.png"),"name":"Copper pickaxe","desc":"+3 Strength\n+4 Speed"},
	54:{"texture_loc":preload("res://textures/items/stone_spear.png"),"type":"weapon","weapon_type":"Spear","dmg":3,"speed":2,"range":64,"big_texture":preload("res://textures/weapons/stone_spear.png"),"name":"Stone spear","desc":"+3 Damage\n+2 Speed\n+4 Range"},
	56:{"texture_loc":preload("res://textures/items/silver.png"),"type":"Item","name":"Silver"},
	57:{"texture_loc":preload("res://textures/items/silver_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":4,"speed":6,"big_texture":preload("res://textures/weapons/silver_pick.png"),"name":"Silver pickaxe","desc":"+4 Strength\n+6 Speed"},
	58:{"texture_loc":preload("res://textures/items/wood_club.png"),"type":"weapon","weapon_type":"Club","dmg":3,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/wood_club.png"),"name":"Wood club","desc":"+3 Damage\n+1 Speed\n+2 Range"},
	59:{"texture_loc":preload("res://textures/items/wood_axe_big.png"),"type":"weapon","weapon_type":"Axe","dmg":4,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/wood_axe.png"),"name":"Wood axe","desc":"+4 Damage\n+2 Speed\n+2 Range"},
	60:{"texture_loc":preload("res://textures/items/wood_machete_big.png"),"type":"weapon","weapon_type":"Machete","dmg":1,"speed":0.1,"range":16,"name":"Wood machete","desc":"+1 Damage\n+0.1 Speed\n+1 Range"},
	61:{"texture_loc":preload("res://textures/items/wood_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":2,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/wood_sword.png"),"name":"Wood sword","desc":"+2 Damage\n+0.5 Speed\n+2 Range"},
	62:{"texture_loc":preload("res://textures/items/barbed_club.png"),"type":"weapon","weapon_type":"Club","dmg":5,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/barbed_club.png"),"name":"Barbed club","desc":"+5 Damage\n+1 Speed\n+2 Range"},
	63:{"texture_loc":preload("res://textures/items/copper_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":7,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/copper_axe.png"),"name":"Copper axe","desc":"+7 Damage\n+2 Speed\n+2 Range"},
	64:{"texture_loc":preload("res://textures/items/copper_dagger.png"),"type":"weapon","weapon_type":"Dagger","dmg":2,"speed":0.1,"range":16,"big_texture":preload("res://textures/weapons/copper_dagger.png"),"name":"Copper dagger","desc":"+2 Damage\n+0.1 Speed\n+1 Range"},
	65:{"texture_loc":preload("res://textures/items/copper_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":4,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/copper_sword.png"),"name":"Copper sword","desc":"+4 Damage\n+0.5 Speed\n+2 Range"},
	66:{"texture_loc":preload("res://textures/items/silver_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":12,"speed":2,"range":32,"big_texture":preload("res://textures/weapons/silver_axe.png"),"name":"Silver axe","desc":"+12 Damage\n+2 Speed\n+2 Range"},
	67:{"texture_loc":preload("res://textures/items/silver_dagger.png"),"type":"weapon","weapon_type":"Dagger","dmg":5,"speed":0.1,"range":16,"big_texture":preload("res://textures/weapons/silver_dagger.png"),"name":"Silver dagger","desc":"+5 Damage\n+0.1 Speed\n+1 Range"},
	68:{"texture_loc":preload("res://textures/items/silver_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":8,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/silver_sword.png"),"name":"Silver sword","desc":"+8 Damage\n+0.5 Speed\n+2 Range"},
	74:{"texture_loc":preload("res://textures/items/rhodonite.png"),"type":"Item","name":"Rhodonite"},
	92:{"texture_loc":preload("res://textures/items/exotic_wood_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":1,"speed":2,"big_texture":preload("res://textures/weapons/exotic_wood_pick.png"),"name":"Exotic wood pickaxe","desc":"+1 Strength\n+2 Speed"},
	93:{"texture_loc":preload("res://textures/items/exotic_wood_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":3,"speed":0.5,"range":32,"big_texture":preload("res://textures/weapons/exotic_wood_sword.png"),"name":"Exotic wood sword","desc":"+3 Damage\n+0.5 Speed\n+2 Range"},
	94:{"texture_loc":preload("res://textures/items/exotic_wood_club.png"),"type":"weapon","weapon_type":"Club","dmg":4,"speed":1,"range":32,"big_texture":preload("res://textures/items/exotic_wood_club.png"),"name":"Exotic wood club","desc":"+4 Damage\n+1 Speed\n+2 Range"},
	95:{"texture_loc":preload("res://textures/items/exotic_barbed_club.png"),"type":"weapon","weapon_type":"Club","dmg":5,"speed":1,"range":32,"big_texture":preload("res://textures/weapons/exotic_barbed_club.png"),"name":"Exotic barbed club","desc":"+5 Damage\n+1 Speed\n+2 Range"},
	96:{"texture_loc":preload("res://textures/items/rhodonite_sword.png"),"type":"weapon","weapon_type":"Sword","dmg":10,"speed":0.25,"range":32,"big_texture":preload("res://textures/weapons/rhodonite_sword.png"),"name":"Rhodonite sword","desc":"+10 Damage\n+0.25 Speed\n+2 Range"},
	97:{"texture_loc":preload("res://textures/items/rhodonite_axe.png"),"type":"weapon","weapon_type":"Axe","dmg":16,"speed":3.5,"range":32,"big_texture":preload("res://textures/weapons/rhodonite_axe.png"),"name":"Rhodonite axe","desc":"+16 Damage\n+3.5 Speed\n+2 Range"},
	98:{"texture_loc":preload("res://textures/items/rhodonite_pick.png"),"type":"Tool","tool_type":"Pickaxe","strength":5,"speed":8,"big_texture":preload("res://textures/weapons/rhodonite_pick.png"),"name":"Rhodonite pickaxe","desc":"+5 Strength\n+8 Speed"},
	99:{"texture_loc":preload("res://textures/items/rhodonite_spear.png"),"type":"weapon","weapon_type":"Spear","dmg":8,"speed":1,"range":96,"big_texture":preload("res://textures/weapons/rhodonite_spear.png"),"name":"Rhodonite spear","desc":"+8 Damage\n+1 Speed\n+6 Range"},
	100:{"texture_loc":preload("res://textures/items/quartz.png"),"type":"Item","name":"Quartz"},
	101:{"texture_loc":preload("res://textures/items/rose_quartz.png"),"type":"Item","name":"Rose quartz"},
	102:{"texture_loc":preload("res://textures/items/purple_quartz.png"),"type":"Item","name":"Purple quartz"},
	103:{"texture_loc":preload("res://textures/items/blue_quartz.png"),"type":"Item","name":"Blue quartz"},
	113:{"texture_loc":preload("res://textures/items/bucket.png"),"type":"Bucket","name":"Silver bucket"},
	114:{"texture_loc":preload("res://textures/items/copper_bucket.png"),"type":"Bucket","name":"Copper bucket"},
	115:{"texture_loc":preload("res://textures/items/water_bucket.png"),"type":"Bucket","name":"Silver bucket of water"},
	116:{"texture_loc":preload("res://textures/items/water_copper_bucket.png"),"type":"Bucket","name":"Copper bucket of water"},
	125:{"texture_loc":preload("res://textures/items/wheat.png"),"type":"Item","name":"Wheat"},
	126:{"texture_loc":preload("res://textures/items/tomato.png"),"type":"Food","name":"Tomato","regen":2},
	127:{"texture_loc":preload("res://textures/items/corn.png"),"type":"Food","name":"Corn","regen":4},
	129:{"texture_loc":preload("res://textures/items/stone_hoe.png"),"type":"Hoe","name":"Stone hoe","big_texture":preload("res://textures/weapons/stone_hoe.png")},
	130:{"texture_loc":preload("res://textures/items/silver_hoe.png"),"type":"Hoe","name":"Silver hoe","big_texture":preload("res://textures/weapons/silver_hoe.png")},
	131:{"texture_loc":preload("res://textures/items/copper_watering_can.png"),"type":"Watering_can","name":"Copper watering can","big_texture":preload("res://textures/weapons/copper_watering_can.png")},
	132:{"texture_loc":preload("res://textures/items/silver_watering_can.png"),"type":"Watering_can","name":"Silver watering can","big_texture":preload("res://textures/weapons/silver_watering_can.png")},
	140:{"texture_loc":preload("res://textures/items/bread.png"),"type":"Food","name":"Bread","regen":8},
}

var fullGrownItemDrops = {
	121:[{"id":121,"amount":[0,3]},{"id":125,"amount":[1,2]}],
	122:[{"id":122,"amount":[0,3]},{"id":126,"amount":[1,2]}],
	123:[{"id":123,"amount":[0,3]},{"id":127,"amount":[1,2]}]
}

signal update_blocks
signal world_loaded

func _ready():
	var _er = StarSystem.connect("planet_ready",self,"start_world")
	_er = Global.connect("loaded_data",self,"start_world")
	Global.pause = false
	if Global.gameStart:
		StarSystem.start_game()

func start_world():
	print("World started")
	if !StarSystem.planetReady:
		yield(StarSystem,"planet_ready")
	#world size stuff
	match Global.gamerules["custom_generation"]:
		"meteor":
			worldSize = Vector2(256,32)
		"":
			worldSize = StarSystem.get_current_world_size()
	$StaticBody2D/Right.position = Vector2(worldSize.x * BLOCK_SIZE.x + 2,(worldSize.y * BLOCK_SIZE.y) / 2)
	$StaticBody2D/Right.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$"../Player/Camera2D".limit_right = worldSize.x * BLOCK_SIZE.x -4
	$"../Player/Camera2D".limit_bottom = worldSize.y * BLOCK_SIZE.y + 24
	$StaticBody2D/Left.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
	$StaticBody2D/Left.position.y = (worldSize.y * BLOCK_SIZE.y) / 2 - 8
	$StaticBody2D/Bottom.shape.extents.y = (worldSize.x * BLOCK_SIZE.x) / 2
	$StaticBody2D/Bottom.position = Vector2((worldSize.x * BLOCK_SIZE.x) / 2,worldSize.y * BLOCK_SIZE.y)
	
	var worldType = StarSystem.find_planet_id(Global.currentPlanet).type["type"]
	get_node("../CanvasLayer/Black").show()
	if !StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere:
		get_node("../CanvasLayer/ParallaxBackground/SkyLayer").hide()
	if worldType == "asteroids":
		hasGravity = false
	if !Global.gameStart:
		Global.playerData.erase("pos")
	if Global.inTutorial:
		player.gender = "Guy"
		armor.armor = {"Helmet":{},"Hat":{},"Chestplate":{"id":32,"amount":1},"Shirt":{},"Leggings":{"id":33,"amount":1},"Pants":{},"Boots":{"id":34,"amount":1},"Shoes":{}}
		armor.emit_signal("updated_armor",armor.armor)
	elif !(Global.gameStart and Global.new):
		load_player_data()
	if Global.new: #This is if this is a new planet
		if Global.gameStart: #This is if the game is a new save
			player.health = Global.gamerules["starting_hp"]
			player.maxHealth = Global.gamerules["max_hp"]
			player.get_node("Textures/body").modulate = Global.playerBase["skin"]
			player.gender = Global.playerBase["sex"]
			inventory.add_to_inventory(4,1)
			armor.armor = {"Helmet":{"id":46,"amount":1},"Hat":{},"Chestplate":{"id":47,"amount":1},"Shirt":{},"Leggings":{"id":48,"amount":1},"Pants":{},"Boots":{"id":49,"amount":1},"Shoes":{}}
			armor.emit_signal("updated_armor",armor.armor)
		#Generates like normal, unless specified to generate a custom world
		generateWorld(worldType if Global.gamerules["custom_generation"] == "" else Global.gamerules["custom_generation"])
	else:
		load_world_data()
	enviroment.set_background(worldType)
	emit_signal("world_loaded")
	get_node("../CanvasLayer/ParallaxBackground2/Sky").init_sky()
	worldLoaded = true
	get_node("../CanvasLayer/Black/AnimationPlayer").play("fadeOut")
	yield(get_tree(),"idle_frame")
	emit_signal("update_blocks")
	Global.gameStart = false
	inventory.update_inventory()
	Global.save("planet",get_world_data())

func generateWorld(worldType : String):
	var worldSeed = int(Global.currentSystemId) + Global.currentPlanet
	seed(worldSeed)
	if worldType == "exotic":
		worldNoise = load("res://noise/exotic.tres")
	else:
		worldNoise = load("res://noise/Main.tres")
	worldNoise.seed = worldSeed
	var copperOre = OpenSimplexNoise.new()
	copperOre.seed = worldSeed;copperOre.period = 2;copperOre.persistence = 0.5;copperOre.lacunarity = 2
	match worldType:
		"terra":
			var seaLevel = 50
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
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,29)
						else:
							set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
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
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,29)
						else:
							set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
		"desert":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					var height = (worldSize.y - (int(worldNoise.get_noise_1d(x) * noiseScale) + worldHeight))
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y >= height and y < height+3:
						set_block_all(pos,14)
					elif y >= height+3 and y < worldSize.y-1:
						set_block_all(pos,22)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
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
					elif y >= height+4 and y < worldSize.y-1:
						set_block_all(pos,3)
					elif y == worldSize.y-1:
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
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,55)
						else:
							set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
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
					elif y >= height+3 and y < worldSize.y-1:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.3:
							set_block_all(pos,55)
						else:
							set_block_all(pos,3)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
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
#						elif get_block(pos - Vector2(0,1),1) == null:
#							if randi() % 3 == 1:
#								set_block(pos - Vector2(0,1),1,6)
#							elif randi() % 3 == 1:
#								set_block(pos - Vector2(0,1),1,7)
					elif y > height and y < height+3:
						set_block_all(pos,70)
					elif y >= height+3 and y < worldSize.y-1:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,73)
						else:
							set_block_all(pos,71)
					elif y == worldSize.y-1:
						set_block_all(pos,144)
		"asteroids":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if asteroidNoise.get_noise_2d(x,y) > 0.4:
						var pos = Vector2(x,y)
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,104 + randi()%4)
						else:
							set_block_all(pos,112)
		"ocean":
			for x in range(worldSize.x):
				var height = (worldSize.y - (int(oceanNoise.get_noise_1d(x) * noiseScale) + worldHeight))
				for y in range(worldSize.y):
					if height > worldSize.y - 4:
						height = worldSize.y - 4
					var pos = Vector2(x,y)
					if y == worldSize.y-1:
						set_block_all(pos,144)
					elif y >= height:
						set_block_all(pos,118)
					elif y > 40:
						set_block(pos,1,117,false,{"water_level":4})
		"meteor":
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
							set_block_all(pos,[29,55,124][randi()%3])
						else:
							set_block_all(pos,3)

func get_world_data() -> Dictionary:
	var data = {}
	data["player"] = {
		"armor":armor.armor,"inventory":inventory.inventory,"inventory_refs":{"j":inventory.jId,"k":inventory.kId},"health":player.health,"max_health":player.maxHealth,"oxygen":player.oxygen,"suit_oxygen":player.suitOxygen,"max_oxygen":player.maxOxygen,"suit_oxygen_max":player.suitOxygenMax,"current_planet":Global.currentPlanet,"current_system":Global.currentSystemId,"pos":player.position,"save_type":"planet","achievements":GlobalGui.completedAchievements,
		"misc_stats":{"meteor_stage":meteors.stage,"meteor_progress_time_left":$"../CanvasLayer/Enviroment/Meteors/StageProgress".time_left}
	}
	data["system"] = StarSystem.get_system_data()
	data["planet"] = {"blocks":[],"entities":entities.get_entity_data(),"rules":worldRules,"left_at_time":Global.globalGameTime,"current_weather":$"..".currentWeather,"weather_time_left":$"../weather/WeatherTimer".time_left}
	for block in $blocks.get_children():
		data["planet"]["blocks"].append({"id":block.id,"layer":block.layer,"position":block.pos,"data":block.data})
	return data

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
	inventory.inventory = playerData["inventory"]
	armor.armor = playerData["armor"]
	armor.emit_signal("updated_armor",armor.armor)
	if playerData.has("inventory_refs"):
		inventory.jId = playerData["inventory_refs"]["j"]
		inventory.kId = playerData["inventory_refs"]["k"]
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

func set_block(pos : Vector2, layer : int, id : int, update = false, data = {}) -> void:
	var blockAtPos = get_block(pos,layer)
	if blockAtPos != null or (id == 0 and blockAtPos != null):
		$blocks.remove_child(blockAtPos)
		blockAtPos.queue_free()
	if id > 0:
		var block
		match blockData[id]["type"]:
			"block":
				block = BLOCK.instance()
			"simple":
				block = SIMPLE_BLOCK.instance()
			"shop":
				block = shops[blockData[id]["shop_type"]].instance()
		block.position = pos * BLOCK_SIZE
		block.pos = pos
		block.id = id
		block.layer = layer
		block.data = data
		block.name = str(pos.x) + "," + str(pos.y) + "," + str(layer)
		block.get_node("Sprite").texture = get_item_texture(id)
		$blocks.add_child(block)
	if update:
		update_area(pos)

func update_area(pos):
	for x in range(pos.x-1,pos.x+2):
		for y in range(pos.y-1,pos.y+2):
			if Vector2(x,y) != pos and get_block(Vector2(x,y),1) != null:
				get_block(Vector2(x,y),1).on_update()
			if get_block(Vector2(x,y),0) != null:
				get_block(Vector2(x,y),0).on_update()

func build_event(action : String, pos : Vector2, layer : int,id = 0, itemAction = true) -> void:
	if action == "Build" and get_block(pos,layer) == null and blockData.has(id) and (!blockData[id].has("can_place_on") or blockData[id]["can_place_on"].has(get_block_id(pos + Vector2(0,1),layer))):
		set_block(pos,layer,id,true)
		if itemAction:
			inventory.remove_id_from_inventory(id,1)
	elif action == "Break" and get_block(pos,layer) != null:
		var block = get_block(pos,layer).id
		if block == 91:
			for item in get_block(pos,layer).data:
				entities.spawn_item({"id":item["id"],"amount":item["amount"]},false,pos*BLOCK_SIZE)
		if itemAction and !Global.godmode:
			var itemsToDrop = blockData[block]["drops"]
			match block:
				121,122,123:
					if get_block(pos,layer).data["plant_stage"] >= 3:
						itemsToDrop = fullGrownItemDrops[block]
			for i in range(itemsToDrop.size()):
				if typeof(itemsToDrop[i]["amount"]) != TYPE_ARRAY:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":itemsToDrop[i]["amount"]},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],itemsToDrop[i]["amount"])
				else:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1))},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1)))
		set_block(pos,layer,0,true)

func _on_GoUp_pressed():
	Global.save("planet",get_world_data())
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
