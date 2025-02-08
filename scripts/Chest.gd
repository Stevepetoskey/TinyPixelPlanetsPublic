extends Control

const CHEST_BTN = preload("res://assets/ChestBtn.tscn")
const CHEST_SIZE = 24

var currentChest = null

@onready var world = $"../../World"
@onready var inventory = $"../Inventory"
@onready var ITEM_STACK_SIZE = inventory.ITEM_STACK_SIZE
@onready var item_container = $ItemScroll/ItemContainer
@onready var transfer_ui: NinePatchRect = $"../Inventory/TransferUI"

func update_chest(chest = currentChest):
	currentChest = chest
	var chestData = currentChest.data
	for child in item_container.get_children():
		child.queue_free()
	for item in range(0,chestData.size()):
		var itemNode = CHEST_BTN.instantiate()
		itemNode.loc = item
		itemNode.get_node("Item").set_item(chestData[item])
		itemNode.get_node("Amount").text = str(chestData[item]["amount"])
		item_container.add_child(itemNode)

func add_to_chest(id:int,amount:int,data:Dictionary) -> Dictionary:
	var chestData = currentChest.data
	if amount > 0:
		var itemData = GlobalData.get_item_data(id)
		if itemData.has("starter_data") and data.is_empty():
			data = itemData["starter_data"].duplicate(true)
		var stackSize = ITEM_STACK_SIZE if !itemData.has("stack_size") else itemData["stack_size"]
		for item in range(chestData.size()):
			if chestData[item]["id"] == id and chestData[item]["data"] == data:
				if chestData[item]["amount"] + amount <= stackSize:
					chestData[item]["amount"] += amount
					amount = 0
				else:
					amount -= ITEM_STACK_SIZE - chestData[item]["amount"]
					chestData[item]["amount"] = stackSize
				update_chest()
		if amount > 0:
			while amount > 0:
				if chestData.size() >= CHEST_SIZE:
					return {"id":id,"amount":amount,"data":data}
				var newAmount = amount
				if amount > stackSize:
					newAmount = stackSize
				chestData.append({"id":id,"amount":newAmount,"data":data})
				amount -= stackSize
		update_chest()
	return {}

func chest_btn_clicked(loc,item):
	var itemData : Dictionary = currentChest.data[loc]
	if !itemData.has("data"): #Ensures parity from older version where not all items were required to have the data tag
		itemData["data"] = {}
	transfer_ui.begin_transfer(itemData,"inventory",loc,"chest")

func mouse_in_btn(loc : int):
	$"../ItemData".display(currentChest.data[loc])

func mouse_out_btn(_loc : int):
	$"../ItemData".hide()
