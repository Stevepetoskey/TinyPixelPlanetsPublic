extends Control

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

#{"id":1,"amount",2}
var inventory = []
var currentPage = 0
var invPause = false
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
		$"../Hotbar/HBoxContainer/BGT".texture.region.position = [Vector2(115,9),Vector2(0,0)][cursor.currentLayer]

func add_to_inventory(id : int,amount : int,drop = true) -> Dictionary:
	if !Global.godmode:
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
							entities.spawn_item({"id":id,"amount":amount},true)
							return {}
						else:
							return {"id":id,"amount":amount}
					var newAmount = amount
					if amount > ITEM_STACK_SIZE:
						newAmount = ITEM_STACK_SIZE
					inventory.append({"id":id,"amount":newAmount})
					amount -= ITEM_STACK_SIZE
		update_inventory()
	return {}

func remove_loc_from_inventory(loc : int) -> void:
	if loc < inventory.size() and !Global.godmode:
		inventory.remove(loc)
		update_inventory()

func remove_id_from_inventory(id : int, amount : int) -> void:
	if !Global.godmode:
		for item in range(inventory.size()):
			if inventory[item]["id"] == id:
				if inventory[item]["amount"] > amount:
					inventory[item]["amount"] -= amount
					update_inventory()
					break
				else:
					remove_loc_from_inventory(item)
					break

func find_item(id : int) -> Dictionary:
	for item in range(inventory.size()):
		if inventory[item]["id"] == id:
			return inventory[item]
	return {}

func update_inventory() -> void:
	
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
		for page in $items.get_children():
			for item in page.get_children():
				item.queue_free()
		#Sets first slot's texture
		slot1.show()
		slot1.get_node("Amount").text = str(inventory[0]["amount"])
		slot1.get_node("Item").texture = world.get_item_texture(inventory[0]["id"])
		#Sets second slot's texture
		if inventory.size() > 1:
			slot2.show()
			slot2.get_node("Amount").text = str(inventory[1]["amount"])
			slot2.get_node("Item").texture = world.get_item_texture(inventory[1]["id"])
		
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
		if !$items.has_node("0"):
			var page0 = Control.new()
			page0.name = "0"
			$items.add_child(page0)
		
		var loc = 0
		var x = 0
		var y = 0
		
		for item in range(2,inventory.size()):
			if (item-1) % ITEM_PER_PAGE == 0:
				if !$items.has_node(str((item-1) / ITEM_PER_PAGE)):
					var page = Control.new()
					page.name = str((item-1) / ITEM_PER_PAGE)
					$items.add_child(page)
				loc = 0;x = 0;y = 0
			var itemNode = INV_BTN.instance()
			itemNode.rect_position = Vector2(x*50,y*16)
			itemNode.loc = item
			itemNode.get_node("Sprite").texture = world.get_item_texture(inventory[item]["id"])
			itemNode.get_node("Amount").text = str(inventory[item]["amount"])
			$items.get_node(str(int((item-1) / float(ITEM_PER_PAGE)))).add_child(itemNode)
			loc += 1
			x += 1
			if x > 1:
				x = 0;y += 1
	else:
		slot1.hide()
	if currentPage > int((inventory.size()-2) / float(ITEM_PER_PAGE)):
		currentPage = int((inventory.size()-2) / float(ITEM_PER_PAGE))
	update_buttons()
	crafting.update_crafting()

func update_buttons() -> void:
	for child in $items.get_children():
		if child.name == str(currentPage):
			child.show()
		else:
			child.hide()
	if currentPage > 0:
		$leftBtn.show()
	else:
		$leftBtn.hide()
	if currentPage < int((inventory.size() -2) / float(ITEM_PER_PAGE)):
		$rightBtn.show()
	else:
		$rightBtn.hide()

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
	elif loc != jRef and loc != kRef:
		if !holding:
			holding = true
			holdingRef = loc
			item.texture_normal = load("res://textures/GUI/main/inventory_holding.png")
		else:
			$change.play()
			var new = inventory[holdingRef].duplicate(true)
			inventory[holdingRef] = inventory[loc].duplicate(true)
			inventory[loc] = new
			update_inventory()

func inventoryToggle(toggle = true,setValue = false,mode = "inventory"):
	holding = false
	if toggle:
		setValue = !visible
	visible = setValue
	Global.pause = setValue
	if visible:
		update_inventory()
	match mode:
		"close":
			crafting.visible = false
			chest.visible = false
		"inventory","crafting_table","oven","smithing_table":
			crafting.visible = setValue
			crafting.update_crafting(mode)
		"chest":
			chest.visible = setValue
			chest.update_chest(world.get_block(cursor.cursorPos,cursor.currentLayer))

func inv_btn_action(location : int,action : String) -> void:
	var item = inventory[location]["id"]
	if world.itemData.has(item) and ["Tool","weapon"].has(world.itemData[item]["type"]):
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
	if !holding:
		if visible:
			inventoryToggle(false,false,"close")
		else:
			inventoryToggle()
	else:
		$change.play()
		var new = inventory[holdingRef].duplicate(true)
		inventory[holdingRef] = inventory[0].duplicate(true)
		inventory[0] = new
		update_inventory()

func _on_InventoryBtn2_pressed():
	if !holding:
		if visible:
			inventoryToggle(false,false,"close")
		else:
			inventoryToggle()
	else:
		$change.play()
		var new = inventory[holdingRef].duplicate(true)
		inventory[holdingRef] = inventory[1].duplicate(true)
		inventory[1] = new
		update_inventory()

func _on_leftBtn_pressed():
	if currentPage > 0:
		currentPage -= 1
		update_buttons()

func _on_rightBtn_pressed():
	if currentPage < int(inventory.size()-2 / float(ITEM_PER_PAGE)):
		currentPage += 1
		update_buttons()
