extends Node2D

const BLOCK = preload("res://assets/Block.tscn")
const BLOCK_SIZE = Vector2(8,8)

export var worldSize = Vector2(16,24)
export var worldNoise : OpenSimplexNoise
export var asteroidNoise : OpenSimplexNoise
export var noiseScale = 15
export var worldHeight = 10

onready var inventory = get_node("../CanvasLayer/Inventory")
onready var enviroment = get_node("../CanvasLayer/Enviroment")
onready var armor = get_node("../CanvasLayer/Inventory/Armor")
onready var player = get_node("../Player")
onready var entities = get_node("../Entities")

var currentPlanet : Object

var worldLoaded = false
var hasGravity = true

var interactableBlocks = [12,16,28,91]

var transparentBlocks = [0,1,6,7,9,11,12,20,24,10,28,30]
var blockData = {
	1:{"texture":preload("res://textures/blocks2X/grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":1,"amount":1}],"name":"Grass block"},
	2:{"texture":preload("res://textures/blocks2X/dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":2,"amount":1}],"name":"Dirt"},
	3:{"texture":preload("res://textures/blocks2X/stone.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Stone"},
	6:{"texture":preload("res://textures/blocks2X/flower1.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Flower 1"},
	7:{"texture":preload("res://textures/blocks2X/flower2.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[],"name":"Flower 2"},
	8:{"texture":preload("res://textures/blocks2X/Cobble.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":8,"amount":1}],"name":"Cobble"},
	9:{"texture":preload("res://textures/blocks/tree_small.png"),"hardness":7,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":[3,6]},{"id":11,"amount":[0,3]}],"name":"Tree"},
	10:{"texture":preload("res://textures/blocks2X/log_front.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":10,"amount":1}],"name":"Log"},
	11:{"texture":preload("res://textures/items/pinecone.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":11,"amount":1}],"name":"Pinecone"},
	12:{"texture":preload("res://textures/blocks2X/crafting_table.png"),"hardness":2,"breakWith":"Axe","canHaverst":1,"drops":[{"id":12,"amount":1}],"name":"Workbench"},
	13:{"texture":preload("res://textures/blocks2X/planks.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":13,"amount":1}],"name":"Planks"},
	14:{"texture":preload("res://textures/blocks2X/sand.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":14,"amount":1}],"name":"Sand"},
	15:{"texture":preload("res://textures/blocks2X/stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":15,"amount":1}],"name":"Stone bricks"},
	16:{"texture":preload("res://textures/blocks2X/oven.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":16,"amount":1}],"name":"Oven"},
	17:{"texture":preload("res://textures/blocks2X/mud_stone.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":17,"amount":1}],"name":"Mud stone"},
	18:{"texture":preload("res://textures/blocks2X/mud_stone_dust.png"),"hardness":0.5,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":18,"amount":1}],"name":"Mud stone dust"},
	19:{"texture":preload("res://textures/blocks2X/mud_stone_bricks.png"),"hardness":1.4,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":19,"amount":1}],"name":"Mud stone bricks"},
	20:{"texture":preload("res://textures/blocks2X/glass_icon.png"),"hardness":0.1,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":20,"amount":1}],"name":"Glass"},
	21:{"texture":preload("res://textures/blocks2X/snow_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":21,"amount":1}],"name":"Snow block"},
	22:{"texture":preload("res://textures/blocks2X/sandstone.png"),"hardness":1.3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":22,"amount":1}],"name":"Sandstone"},
	23:{"texture":preload("res://textures/blocks2X/sandstone_bricks.png"),"hardness":2.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":23,"amount":1}],"name":"Sandstone bricks"},
	24:{"texture":preload("res://textures/blocks2X/grass_snow.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":24,"amount":1}],"name":"Grass snow"},
	25:{"texture":preload("res://textures/blocks2X/clay.png"),"hardness":0.4,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":25,"amount":1}],"name":"Clay"},
	26:{"texture":preload("res://textures/blocks2X/bricks.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":26,"amount":1}],"name":"Bricks"},
	27:{"texture":preload("res://textures/blocks2X/brick_shingles.png"),"hardness":1.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":27,"amount":1}],"name":"Brick shingles"},
	28:{"texture":preload("res://textures/blocks2X/smithing_table.png"),"hardness":2.5,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":28,"amount":1}],"name":"Smithing table"},
	29:{"texture":preload("res://textures/blocks2X/copper_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":29,"amount":1}],"name":"Copper ore"},
	30:{"texture":preload("res://textures/blocks2X/platform_full.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":30,"amount":1}],"name":"Wood platform"},
	55:{"texture":preload("res://textures/blocks2X/silver_ore.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":55,"amount":1}],"name":"Silver ore"},
	69:{"texture":preload("res://textures/blocks2X/exotic_grass_block.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":69,"amount":1}],"name":"Exotic grass block"},
	70:{"texture":preload("res://textures/blocks2X/exotic_dirt.png"),"hardness":0.3,"breakWith":"Shovel","canHaverst":0,"drops":[{"id":70,"amount":1}],"name":"Exotic dirt"},
	71:{"texture":preload("res://textures/blocks2X/exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":71,"amount":1}],"name":"Exotic stone"},
	72:{"texture":preload("res://textures/blocks2X/exotic_stone_bricks.png"),"hardness":3.5,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":72,"amount":1}],"name":"Exotic stone bricks"},
	73:{"texture":preload("res://textures/blocks2X/rhodonite_ore.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":74,"amount":1}],"name":"Rhodonite ore"},
	75:{"texture":preload("res://textures/blocks2X/carved_exotic_stone.png"),"hardness":3,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":75,"amount":1}],"name":"Carved exotic stone"},
	76:{"texture":preload("res://textures/blocks2X/exotic_sapling.png"),"hardness":9,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":[3,6]},{"id":85,"amount":[0,3]}],"name":"Exotic tree"},
	77:{"texture":preload("res://textures/blocks2X/exotic_log_front.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":77,"amount":1}],"name":"Exotic log"},
	78:{"texture":preload("res://textures/blocks2X/exotic_planks.png"),"hardness":1.5,"breakWith":"Axe","canHaverst":1,"drops":[{"id":78,"amount":1}],"name":"Exotic planks"},
	79:{"texture":preload("res://textures/blocks2X/exotic_wood_window.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":79,"amount":1}],"name":"Exotic wood window"},
	80:{"texture":preload("res://textures/blocks2X/wood_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":80,"amount":1}],"name":"Wood window"},
	81:{"texture":preload("res://textures/blocks2X/copper_window.png"),"hardness":0.5,"breakWith":"Pickaxe","canHaverst":0,"drops":[{"id":81,"amount":1}],"name":"Copper window"},
	82:{"texture":preload("res://textures/blocks2X/mossy_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":82,"amount":1}],"name":"Mossy stone bricks"},
	83:{"texture":preload("res://textures/blocks2X/cracked_stone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":83,"amount":1}],"name":"Cracked stone bricks"},
	84:{"texture":preload("res://textures/blocks2X/mossy_cobblestone.png"),"hardness":0.75,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":84,"amount":1}],"name":"Mossy cobble"},
	85:{"texture":preload("res://textures/blocks2X/exotic_sapling.png"),"hardness":0,"breakWith":"All","canHaverst":0,"drops":[{"id":85,"amount":1}],"name":"Exotic sapling"},
	86:{"texture":preload("res://textures/blocks2X/cracked_mud_bricks.png"),"hardness":1.2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":86,"amount":1}],"name":"Cracked mud bricks"},
	87:{"texture":preload("res://textures/blocks2X/cracked_sandstone_bricks.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":87,"amount":1}],"name":"Cracked sandstone bricks"},
	88:{"texture":preload("res://textures/blocks2X/copper_block.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":2,"drops":[{"id":88,"amount":1}],"name":"Copper block"},
	89:{"texture":preload("res://textures/blocks2X/silver_block.png"),"hardness":5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":89,"amount":1}],"name":"Silver block"},
	90:{"texture":preload("res://textures/blocks2X/rhodonite_block.png"),"hardness":6,"breakWith":"Pickaxe","canHaverst":4,"drops":[{"id":90,"amount":1}],"name":"Rhodonite block"},
	91:{"texture":preload("res://textures/blocks2X/chest.png"),"hardness":1,"breakWith":"Axe","canHaverst":1,"drops":[{"id":91,"amount":1}],"name":"Chest"},
	104:{"texture":preload("res://textures/blocks2X/quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":100,"amount":[1,3]}],"name":"Quartz ore"},
	105:{"texture":preload("res://textures/blocks2X/rose_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":101,"amount":[1,3]}],"name":"Rose quartz ore"},
	106:{"texture":preload("res://textures/blocks2X/purple_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":102,"amount":[1,3]}],"name":"Purple quartz ore"},
	107:{"texture":preload("res://textures/blocks2X/blue_quartz_ore.png"),"hardness":4,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":103,"amount":[1,3]}],"name":"Blue quartz ore"},
	108:{"texture":preload("res://textures/blocks2X/quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":108,"amount":1}],"name":"Quartz block"},
	109:{"texture":preload("res://textures/blocks2X/rose_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":109,"amount":1}],"name":"Rose quartz block"},
	110:{"texture":preload("res://textures/blocks2X/purple_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":110,"amount":1}],"name":"Purple quartz block"},
	111:{"texture":preload("res://textures/blocks2X/blue_quartz_block.png"),"hardness":4.5,"breakWith":"Pickaxe","canHaverst":3,"drops":[{"id":111,"amount":1}],"name":"Blue quartz block"},
	112:{"texture":preload("res://textures/blocks2X/asteroid_rock.png"),"hardness":2,"breakWith":"Pickaxe","canHaverst":1,"drops":[{"id":112,"amount":1}],"name":"Asteroid rock"},
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
}

signal update_blocks
signal world_loaded

func _ready():
	StarSystem.connect("planet_ready",self,"start_world")
	Global.connect("loaded_data",self,"start_world")
	Global.pause = false
	if Global.gameStart:
		StarSystem.start_game()

#func _process(delta):
#	print(Engine.get_frames_per_second())

func start_world():
	print("World started")
	if !StarSystem.planetReady:
		yield(StarSystem,"planet_ready")
	#world size stuff
	worldSize = StarSystem.get_current_world_size()
#	get_node("../Player/Camera2D").limit_right = worldSize.x * BLOCK_SIZE.x - 4
#	get_node("../Player/Camera2D").limit_bottom = (worldSize.y+1) * BLOCK_SIZE.y - 4
	$StaticBody2D/Right.position = Vector2(worldSize.x * BLOCK_SIZE.x + 2,(worldSize.y * BLOCK_SIZE.y) / 2)
	$StaticBody2D/Right.shape.extents.y = (worldSize.y * BLOCK_SIZE.y) / 2
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
	if Global.new:
		#StarSystem.visitedPlanets.append(Global.currentPlanet)
		if Global.gameStart:
			player.gender = Global.playerBase["sex"]
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
	Global.save(get_world_data())

func generateWorld(worldType : String):
	var worldSeed = StarSystem.currentSeed + Global.currentPlanet
	seed(worldSeed)
	if worldType == "exotic":
		worldNoise = load("res://noise/exotic.tres")
	else:
		worldNoise = load("res://noise/Main.tres")
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
					elif y >= height+3:
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,73)
						else:
							set_block_all(pos,71)
		"asteroids":
			for x in range(worldSize.x):
				for y in range(worldSize.y):
					if asteroidNoise.get_noise_2d(x,y) > 0.4:
						var pos = Vector2(x,y)
						if abs(copperOre.get_noise_2d(x,y)) >= 0.4:
							set_block_all(pos,104 + randi()%4)
						else:
							set_block_all(pos,112)
						

func get_world_data(quit = true) -> Dictionary:
	var data = {}
	data["player"] = {"armor":armor.armor,"inventory":inventory.inventory,"inventory_refs":{"j":inventory.jId,"k":inventory.kId},"health":player.health,"max_health":player.maxHealth,"oxygen":player.oxygen,"suit_oxygen":player.suitOxygen,"max_oxygen":player.maxOxygen,"suit_oxygen_max":player.suitOxygenMax,"current_planet":Global.currentPlanet,"current_system":StarSystem.currentSeed,"pos":player.position}
	data["system"] = StarSystem.get_system_data()
	data["planet"] = {"blocks":[],"entities":entities.get_entity_data()}
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
	if playerData.has("pos"):
		player.position = playerData["pos"]
	inventory.inventory = playerData["inventory"]
	armor.armor = playerData["armor"]
	armor.emit_signal("updated_armor",armor.armor)
	if playerData.has("inventory_refs"):
		inventory.jId = playerData["inventory_refs"]["j"]
		inventory.kId = playerData["inventory_refs"]["k"]
		inventory.update_inventory()

func load_world_data() -> void:#data : Dictionary) -> void:
	#Loads planet data
	var planetData = Global.load_planet(StarSystem.currentSeed,Global.currentPlanet)
	entities.load_entities(planetData["entities"])
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
	if get_block(pos,layer) != null or (id == 0 and get_block(pos,layer) != null):
		get_block(pos,layer).queue_free()
		yield(get_tree(),"idle_frame")
	if id > 0:
		var block = BLOCK.instance()
		block.position = pos * BLOCK_SIZE
		block.id = id
		block.layer = layer
		block.data = data
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
		if block == 91:
			for item in get_block(pos,layer).data:
				entities.spawn_item({"id":item["id"],"amount":item["amount"]},false,pos*BLOCK_SIZE)
		set_block(pos,layer,0,true)
		if itemAction and !Global.godmode:
			var itemsToDrop = blockData[block]["drops"]
			for i in range(itemsToDrop.size()):
				if typeof(itemsToDrop[i]["amount"]) != TYPE_ARRAY:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":itemsToDrop[i]["amount"]},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],itemsToDrop[i]["amount"])
				else:
					entities.spawn_item({"id":itemsToDrop[i]["id"],"amount":int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1))},false,pos*BLOCK_SIZE)
					#inventory.add_to_inventory(itemsToDrop[i]["id"],int(rand_range(itemsToDrop[i]["amount"][0],itemsToDrop[i]["amount"][1] + 1)))

func _on_GoUp_pressed():
	Global.save(get_world_data(false))
	StarSystem.start_space()
