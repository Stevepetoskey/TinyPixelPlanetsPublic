extends Control

var typeUpgradeAmount = {
	"armor":3,
	"weapon":3,
	"tool":3
}

@onready var inventory: Control = $"../Inventory"
@onready var world: Node2D = $"../../World"

var slots = {
	"main":{"id":0,"amount":0,"data":{}},
	"left":{"id":0,"amount":0,"data":{}},
	"top":{"id":0,"amount":0,"data":{}},
	"right":{"id":0,"amount":0,"data":{}}
}

func _on_mainslot_pressed() -> void:
	if slots["main"]["id"] == 0 and inventory.holding: #Checks if empty slot
		if typeUpgradeAmount.has(world.get_item_data(inventory.inventory[inventory.holdingRef]["id"])["type"]): #Checks if item can be upgraded
			slots["main"] = inventory.inventory[inventory.holdingRef]
			inventory.remove_loc_from_inventory(inventory.holdingRef)
	elif slots["main"]["id"] != 0 and !inventory.holding:
		pass
	
