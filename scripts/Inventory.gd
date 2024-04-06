extends Control

const BACKGROUND_TEXTURE = preload("res://textures/GUI/main/hotbar/background.png")
const FOREGROUND_TEXTURE = preload("res://textures/GUI/main/hotbar/forground.png")
const INV_BTN = preload("res://assets/InventoryBtn.tscn")
const ITEM_PER_PAGE = 8
var INVENTORY_SIZE = 20
const ITEM_STACK_SIZE = 99

onready var world = get_node("../../World")
onready var slot1 = get_node("../Hotbar/InventoryBtn")
onready var slot2 = $"../Hotbar/InventoryBtn2"
onready var jAction = get_node("../Hotbar/J")
onready var kAction = get_node("../Hotbar/K")
onready var cursor = get_node("../../Cursor")
onready var crafting = get_node("../Crafting")
onready var chest = get_node("../Chest")
onready var entities = $"../../Entities"
onready var item_container = $ItemScroll/ItemContainer
onready var shop: Control = $"../Shop"

#{"id":1,"amount",2}
var inventory = []
var jRef = -1 #Where the j reference is located in inventory
var kRef = -1
var jId = 0
var kId = 0

var holding = false
var holdingRef = -1

func _ready():
	update_inventory()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and visible:
		yield(get_tree(),"idle_frame")
		inventoryToggle(false,false,"close")
	if Input.is_action_just_pressed("Inventory") and !Global.pause:
		inventoryToggle()
	if Input.is_action_just_pressed("background_toggle") and !Global.pause:
		cursor.currentLayer = int(!bool(cursor.currentLayer))
		$"../Hotbar/HBoxContainer/BGT".texture = [BACKGROUND_TEXTURE,FOREGROUND_TEXTURE][cursor.currentLayer]

func add_to_inventory(id : int,amount : int,drop = true,data := {}) -> Dictionary:
	if !Global.godmode:
		match id: #For achievements
			31:
				GlobalGui.complete_achievement("An upgrade")
			98:
				GlobalGui.complete_achievement("Top of the line")
		if world.get_item_data(id).has("type") and world.get_item_data(id)["type"] == "weapon":
			GlobalGui.complete_achievement("Ready for battle")
		$collect.play()
		if amount > 0:
			for item in range(inventory.size()):
				if inventory[item]["id"] == id:
					if inventory[item]["amount"] + amount <= ITEM_STACK_SIZE:
						inventory[item]["amount"] += amount
						amount = 0
					else:
						amount -= ITEM_STACK_SIZE - inventory[item]["amount"]
						inventory[item]["amount"] = ITEM_STACK_SIZE
			if amount > 0:
				while amount > 0:
					if inventory.size() >= INVENTORY_SIZE:
						update_inventory()
						if drop:
							entities.spawn_item({"id":id,"amount":amount,"data":data},true)
							return {}
						else:
							return {"id":id,"amount":amount,"data":data}
					var newAmount = amount
					if amount > ITEM_STACK_SIZE:
						newAmount = ITEM_STACK_SIZE
					inventory.append({"id":id,"amount":newAmount,"data":data})
					amount -= ITEM_STACK_SIZE
		update_inventory()
	return {}

func remove_loc_from_inventory(loc : int) -> void:
	if loc < inventory.size() and !Global.godmode:
		inventory.remove(loc)
		update_inventory()

func remove_amount_at_loc(loc : int,amount : int) -> void:
	if loc < inventory.size() and !Global.godmode:
		inventory[loc]["amount"] -= amount
		if inventory[loc]["amount"] <= 0:
			remove_loc_from_inventory(loc)
		else:
			update_inventory()

func remove_id_from_inventory(id : int, amount : int) -> void:
	var toRemove = []
	if !Global.godmode:
		for item in range(inventory.size()):
			if inventory[item]["id"] == id:
				if inventory[item]["amount"] > amount:
					inventory[item]["amount"] -= amount
					break
				else:
					amount -= inventory[item]["amount"]
					toRemove.append(item)
					if amount <= 0:
						break
	for remove in toRemove:
		remove_loc_from_inventory(remove)
	update_inventory()

func find_item(id : int) -> Dictionary:
	for item in range(inventory.size()):
		if inventory[item]["id"] == id:
			return inventory[item]
	return {}

func count_id(id : int) -> int:
	var count : int = 0
	for item in inventory:
		if item["id"] == id:
			count += item["amount"]
	return count

func update_inventory() -> void:
	#updates blues amount
	$Blues/Label.text = "*" + str(Global.blues)
	
	if Global.godmode:
		INVENTORY_SIZE = world.blockData.size() + world.itemData.size() + 5
		for block in world.blockData:
			if find_item(block).empty():
				inventory.append({"id":block,"amount":1})
		for item in world.itemData:
			if find_item(item).empty():
				inventory.append({"id":item,"amount":1})
	
	holding = false
	holdingRef = -1
	
	#Gets j and k refs
	if !find_item(jId).empty():
		jRef = inventory.find(find_item(jId))
	else:
		jRef = -1
		jId = 0
	if !find_item(kId).empty():
		kRef = inventory.find(find_item(kId))
	else:
		kRef = -1
		kId = 0
	
	if !inventory.empty():
		#clears all items
		for item in item_container.get_children():
			item.queue_free()
		#Sets first slot's texture
		slot1.show()
		slot1.get_node("Amount").text = str(inventory[0]["amount"])
		slot1.get_node("Item").texture = get_item_texture(inventory[0]["id"],0)
		if jRef == 0:
			slot1.texture_normal = load("res://textures/GUI/main/hotbar/hotbar1_j.png")
		elif kRef == 0:
			slot1.texture_normal = load("res://textures/GUI/main/hotbar/hotbar1_k.png")
		else:
			slot1.texture_normal = load("res://textures/GUI/main/hotbar/hotbar1.png")
		#Sets second slot's texture
		if inventory.size() > 1:
			slot2.show()
			slot2.get_node("Amount").text = str(inventory[1]["amount"])
			slot2.get_node("Item").texture = get_item_texture(inventory[1]["id"],1)
			if jRef == 1:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_j.png")
			elif kRef == 1:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_k.png")
			else:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2.png")
		else:
			slot2.hide()
		
		#Sets J and K ref's texture
		if jRef != -1:
			jAction.get_node("Item").texture = world.get_item_texture(inventory[jRef]["id"])
		else:
			jAction.get_node("Item").texture = null
		if kRef != -1:
			kAction.get_node("Item").texture = world.get_item_texture(inventory[kRef]["id"])
		else:
			kAction.get_node("Item").texture = null
		
		#Creates items
		for itemLoc in range(2,inventory.size()):
			var itemNode = INV_BTN.instance()
			itemNode.loc = itemLoc
			itemNode.get_node("Sprite").texture = get_item_texture(inventory[itemLoc]["id"],itemLoc)
			itemNode.get_node("Amount").text = str(inventory[itemLoc]["amount"])
			item_container.add_child(itemNode)
	else:
		slot1.hide()
	crafting.update_crafting()

func get_item_texture(id : int, loc : int):
	match id:
		113:
			return load("res://textures/items/" +("water_" if inventory[loc].has("data") and inventory[loc]["data"].has("water") and inventory[loc]["data"]["water"] > 0 else "")+ "bucket.png")
		114:
			return load("res://textures/items/" +("water_" if inventory[loc].has("data") and inventory[loc]["data"].has("water") and inventory[loc]["data"]["water"] > 0 else "")+ "copper_bucket.png")
		_:
			return world.get_item_texture(id)

func inv_btn_clicked(loc : int,item : Object):
	if chest.visible:
		var leftover = chest.add_to_chest(inventory[loc]["id"],inventory[loc]["amount"])
		if loc == jRef:
			jId = 0
		if loc == kRef:
			kId = 0
		inventory.remove(loc)
		if leftover.empty():
			update_inventory()
			chest.update_chest()
		else:
			add_to_inventory(leftover["id"],leftover["amount"])
	else:
		if !holding:
			holding = true
			holdingRef = loc
			item.texture_normal = load("res://textures/GUI/main/inventory/inventory_holding.png")
		else:
			$change.play()
			var new = inventory[holdingRef].duplicate(true)
			if holdingRef == jRef:
				jRef = loc
			elif holdingRef == kRef:
				kRef = loc
			elif loc == jRef:
				jRef == holdingRef
			elif loc == kRef:
				kRef == holdingRef
			inventory[holdingRef] = inventory[loc].duplicate(true)
			inventory[loc] = new
			update_inventory()

func mouse_in_btn(loc : int):
	if inventory.has(loc):
		var itemData = world.get_item_data(inventory[loc]["id"])
		if itemData.has("name"):
			var text = itemData["name"]
			if itemData.has("desc"):
				text += "\n" + itemData["desc"]
			$"../ItemData".show()
			$"../ItemData".text = text

func mouse_out_btn(_loc : int):
	$"../ItemData".hide()

func inventoryToggle(toggle = true,setValue = false,mode = "inventory"):
	GlobalGui.close_ach()
	$"../ItemData".hide()
	holding = false
	if toggle:
		setValue = !visible
	visible = setValue
	Global.pause = setValue
	if visible:
		update_inventory()
	match mode:
		"close":
			crafting.hide()
			chest.hide()
			shop.hide()
		"inventory","crafting_table","oven","smithing_table":
			crafting.visible = setValue
			crafting.update_crafting(mode)
		"chest":
			chest.visible = setValue
			chest.update_chest(world.get_block(cursor.cursorPos,cursor.currentLayer))
		"lily_mart","skips_stones":
			shop.pop_up(mode)

func inv_btn_action(location : int,action : String) -> void:
	var item = inventory[location]["id"]
	if world.itemData.has(item) and ["Tool","weapon","Hoe"].has(world.itemData[item]["type"]):
		$equip.play()
		match action:
			"j":
				if jRef == location:
					jId = 0
				elif kRef != location:
					jId = item
			"k":
				if kRef == location:
					kId = 0
				elif jRef != location:
					kId = item
	update_inventory()

func _on_InventoryBtn_pressed():
	if visible:
		if chest.visible:
			var leftover = chest.add_to_chest(inventory[0]["id"],inventory[0]["amount"])
			if jRef == 0:
				jId = 0
			if kRef == 0:
				kId = 0
			inventory.remove(0)
			if leftover.empty():
				update_inventory()
				chest.update_chest()
			else:
				add_to_inventory(leftover["id"],leftover["amount"])
		else:
			if !holding:
				holding = true
				holdingRef = 0
				slot1.texture_normal = load("res://textures/GUI/main/hotbar/hotbar1_selected.png")
			else:
				$change.play()
				var new = inventory[holdingRef].duplicate(true)
				if holdingRef == jRef:
					jRef = 0
				elif holdingRef == kRef:
					kRef = 0
				elif 0 == jRef:
					jRef == holdingRef
				elif 0 == kRef:
					kRef == holdingRef
				inventory[holdingRef] = inventory[0].duplicate(true)
				inventory[0] = new
				update_inventory()

func _on_InventoryBtn2_pressed():
	if visible:
		if chest.visible:
			var leftover = chest.add_to_chest(inventory[1]["id"],inventory[1]["amount"])
			if jRef == 1:
				jId = 1
			if kRef == 1:
				kId = 1
			inventory.remove(1)
			if leftover.empty():
				update_inventory()
				chest.update_chest()
			else:
				add_to_inventory(leftover["id"],leftover["amount"])
		else:
			if !holding:
				holding = true
				holdingRef = 1
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_selected.png")
			else:
				$change.play()
				var new = inventory[holdingRef].duplicate(true)
				if holdingRef == jRef:
					jRef = 1
				elif holdingRef == kRef:
					kRef = 1
				elif 1 == jRef:
					jRef == holdingRef
				elif 1 == kRef:
					kRef == holdingRef
				inventory[holdingRef] = inventory[1].duplicate(true)
				inventory[1] = new
				update_inventory()
