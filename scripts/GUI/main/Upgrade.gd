extends Control

const UPGRADE_HOLD = preload("res://textures/GUI/main/upgrade/upgrade_module_hold.png")

var typeUpgradeAmount = {
	"armor":3,
	"weapon":3,
	"tool":3
}

@onready var main: Node2D = $"../.."
@onready var inventory: Control = $"../Inventory"
@onready var world: Node2D = $"../../World"
@onready var left_slot: TextureRect = $ItemHold/LeftSlot
@onready var top_slot: TextureRect = $ItemHold/TopSlot
@onready var right_slot: TextureRect = $ItemHold/RightSlot
@onready var main_item: TextureRect = $ItemHold/Mainslot/Item
@onready var left_slot_btn: TextureButton = $ItemHold/LeftSlot/LeftSlotBtn
@onready var top_slot_btn: TextureButton = $ItemHold/TopSlot/TopSlotBtn
@onready var right_slot_btn: TextureButton = $ItemHold/RightSlot/RightSlotBtn
@onready var main_slot_btn: TextureButton = $ItemHold/Mainslot

var slots = {
	"main":GlobalData.emptyItem.duplicate(true),
	"left":GlobalData.emptyItem.duplicate(true),
	"top":GlobalData.emptyItem.duplicate(true),
	"right":GlobalData.emptyItem.duplicate(true)
}

func pop_up() -> void:
	update_upgrade()
	show()

func clear() -> void:
	if slots["main"]["id"] != 0:
		for i in range(3):
			var currentSlot = [left_slot,top_slot,right_slot][i]
			currentSlot.get_node("Animation").play("RESET")
		inventory.add_to_inventory(slots["main"]["id"],slots["main"]["amount"],true,slots["main"]["data"].duplicate(true))
		slots["main"] = GlobalData.emptyItem.duplicate(true)
	hide()
	update_upgrade()

func _ready() -> void:
	var btnDict : Dictionary = {main_slot_btn:"main",left_slot_btn:"left",top_slot_btn:"top",right_slot_btn:"right"}
	for btn : TextureButton in btnDict:
		if btn != main_slot_btn:
			btn.pressed.connect(upgrade_slot_pressed.bind(btnDict[btn]))
		btn.mouse_entered.connect(mouse_in_btn.bind(btnDict[btn]))
		btn.mouse_exited.connect(mouse_out_btn)

func upgrade_slot_pressed(slot : String) -> void:
	if slots["main"]["id"] != 0:
		var slotAnimation : AnimationPlayer = {"left":$ItemHold/LeftSlot/Animation,"top":$ItemHold/TopSlot/Animation,"right":$ItemHold/RightSlot/Animation}[slot]
		var slotData : Dictionary = slots[slot]
		var mainItemData : Dictionary = GlobalData.get_item_data(slots["main"]["id"])
		if inventory.holding:
			var holdingItemData : Dictionary = inventory.inventory[inventory.holdingRef]
			var applyTo : String = world.upgrades[holdingItemData["data"]["upgrade"]]["apply_to"]
			if holdingItemData["id"] == 215 and world.upgrades.has(holdingItemData["data"]["upgrade"]) and (applyTo == mainItemData["type"] or (mainItemData["type"] == "armor" and mainItemData["armor_data"]["armor_type"] == applyTo)):
				if slotData["id"] == 0:
					slots[slot] = holdingItemData.duplicate(true)
					slotAnimation.play("power")
					slots["main"]["data"]["upgrades"][slot] = slots[slot]["data"]["upgrade"]
					inventory.remove_loc_from_inventory(inventory.holdingRef)
					update_upgrade()
				else:
					var toInventory = slotData.duplicate(true)
					slots[slot] = holdingItemData.duplicate(true)
					slots["main"]["data"]["upgrades"][slot] = slots[slot]["data"]["upgrade"]
					inventory.inventory[inventory.holdingRef] = toInventory
					update_upgrade()
		elif slotData["id"] != 0:
			inventory.add_to_inventory(slotData["id"],slotData["amount"],true,slotData["data"].duplicate(true))
			slots[slot] = GlobalData.emptyItem.duplicate(true)
			slotAnimation.play("unpower")
			slots["main"]["data"]["upgrades"][slot] = ""
			update_upgrade()

func _on_mainslot_pressed() -> void:
	if slots["main"]["id"] == 0 and inventory.holding: #Checks if empty slot
		if typeUpgradeAmount.has(GlobalData.get_item_data(inventory.inventory[inventory.holdingRef]["id"])["type"]): #Checks if item can be upgraded
			slots["main"] = inventory.inventory[inventory.holdingRef]
			inventory.remove_loc_from_inventory(inventory.holdingRef)
			if slots["main"]["data"].has("upgrades"):
				var itemUpgrades : Dictionary = slots["main"]["data"]["upgrades"]
				for slot : String in itemUpgrades:
					slots[slot] = GlobalData.emptyItem.duplicate(true) if itemUpgrades[slot] == "" else {"id":215,"amount":1,"data":{"upgrade":itemUpgrades[slot]}}
			else:
				slots["main"]["data"]["upgrades"] = {"left":"","top":"","right":""}
				for slot : String in ["left","top","right"]:
					slots[slot] = GlobalData.emptyItem.duplicate(true)
			for slot in [left_slot,top_slot,right_slot]:
				slot.hide()
			update_upgrade()
			for i in range(3):
				var currentSlot = [left_slot,top_slot,right_slot][i]
				if i < typeUpgradeAmount[GlobalData.get_item_data(slots["main"]["id"])["type"]]:
					currentSlot.get_node("Animation").play("start")
					await currentSlot.get_node("Animation").animation_finished
					if slots["main"]["data"]["upgrades"][["left","top","right"][i]] != "":
						currentSlot.get_node("Animation").play("power")
	elif slots["main"]["id"] != 0 and !inventory.holding:
		for i in range(3):
			var currentSlot = [left_slot,top_slot,right_slot][i]
			if i < typeUpgradeAmount[GlobalData.get_item_data(slots["main"]["id"])["type"]]:
				currentSlot.get_node("Animation").play("remove")
			else:
				currentSlot.hide()
		inventory.add_to_inventory(slots["main"]["id"],slots["main"]["amount"],true,slots["main"]["data"].duplicate(true))
		slots["main"] = GlobalData.emptyItem.duplicate(true)
		update_upgrade()

func update_upgrade() -> void:
	main_item.set_item(slots["main"])
	$ItemHold/LeftSlot/LeftSlotBtn/Item.set_item(slots["left"])
	$ItemHold/TopSlot/TopSlotBtn/Item.set_item(slots["top"])
	$ItemHold/RightSlot/RightSlotBtn/Item.set_item(slots["right"])

func mouse_in_btn(slot : String):
	$"../ItemData".display(slots[slot])

func mouse_out_btn():
	$"../ItemData".hide()
