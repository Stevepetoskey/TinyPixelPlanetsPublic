extends Node

var item_type_defualt_data : Dictionary = {
	"Tool":{"upgrades":[]}
}

var armor_buffs : Dictionary = {
	"air_tight":{"requires":[46,47,48,49]},
	"cold_resistance":{"requires":[207,208,209,210]},
	"heat_resistance":{"requires":[211,212,213,214]}
}

var blockData : Dictionary = {}

var itemData : Dictionary = {}

var autoSaveTimes : Array = [0,300,900,2700,3600,7200]
var timeFactor : float = 10 # 10
var emptyItem : Dictionary = {"id":0,"amount":0,"data":{}}

func is_upgraded(item_data : Dictionary) -> bool:
	return (item_data.has("upgrades") and (item_data["upgrades"]["left"] != "" or item_data["upgrades"]["top"] != "" or item_data["upgrades"]["right"] != "")) or (item_data.has("upgrade") and item_data["upgrade"] != "")

func get_item_data(item_id : int) -> Dictionary:
	if blockData.has(item_id):
		return blockData[item_id]
	elif itemData.has(item_id):
		return itemData[item_id]
	return {}

func get_item_stack_size(item_id : int) -> int:
	if get_item_data(item_id).has("stack_size"):
		return get_item_data(item_id)["stack_size"]
	else:
		return 99

func get_item_texture(item_id : int) -> Texture2D:
	if blockData.has(item_id):
		return load("res://textures/" + blockData[item_id]["texture"])
	elif itemData.has(item_id):
		return load("res://textures/" + itemData[item_id]["texture"])
	return null

func get_item_big_texture(item_id : int) -> Texture2D:
	if itemData.has(item_id) and itemData[item_id].has("big_texture"):
		return load("res://textures/" + itemData[item_id]["big_texture"])
	return null
