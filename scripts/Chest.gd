extends Control

const CHEST_BTN = preload("res://assets/ChestBtn.tscn")
const CHEST_SIZE = 8

var currentChest = null

onready var world = $"../../World"
onready var inventory = $"../Inventory"
onready var ITEM_STACK_SIZE = inventory.ITEM_STACK_SIZE

func update_chest(chest = currentChest):
	currentChest = chest
	var chestData = currentChest.data
	for child in $items.get_children():
		child.queue_free()
	var loc = 0
	var x = 0; var y = 0
	for item in range(0,chestData.size()):
		var itemNode = CHEST_BTN.instance()
		itemNode.rect_position = Vector2(x*50,y*16)
		itemNode.loc = item
		itemNode.get_node("Sprite").texture = world.get_item_texture(chestData[item]["id"])
		itemNode.get_node("Amount").text = str(chestData[item]["amount"])
		$items.add_child(itemNode)
		loc += 1
		x += 1
		if x > 1:
			x = 0;y += 1

func add_to_chest(id:int,amount:int) -> Dictionary:
	var chestData = currentChest.data
	if amount > 0:
		for item in range(chestData.size()):
			if chestData[item]["id"] == id:
				if chestData[item]["amount"] + amount <= ITEM_STACK_SIZE:
					chestData[item]["amount"] += amount
					amount = 0
				else:
					amount -= ITEM_STACK_SIZE - chestData[item]["amount"]
					chestData[item]["amount"] = ITEM_STACK_SIZE
				update_chest()
		if amount > 0:
			while amount > 0:
				if chestData.size() >= CHEST_SIZE:
					return {"id":id,"amount":amount}
				var newAmount = amount
				if amount > ITEM_STACK_SIZE:
					newAmount = ITEM_STACK_SIZE
				chestData.append({"id":id,"amount":newAmount})
				amount -= ITEM_STACK_SIZE
		update_chest()
	return {}

func chest_btn_clicked(loc,item):
	var itemData = currentChest.data[loc]
	currentChest.data.remove(loc)
	var leftover = inventory.add_to_inventory(itemData["id"],itemData["amount"])
	if !leftover.empty():
		add_to_chest(leftover["id"],leftover["amount"])
	else:
		update_chest()
	inventory.update_inventory()

func mouse_in_btn(loc : int):
	var itemData = world.get_item_data(currentChest.data[loc]["id"])
	if itemData.has("name"):
		var text = itemData["name"]
		if itemData.has("desc"):
			text += "\n" + itemData["desc"]
		$"../ItemData".show()
		$"../ItemData".text = text

func mouse_out_btn(_loc : int):
	$"../ItemData".hide()
