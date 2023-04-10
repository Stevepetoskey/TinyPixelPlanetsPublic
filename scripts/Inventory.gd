extends Control

const INV_BTN = preload("res://assets/InventoryBtn.tscn")
const ITEM_PER_PAGE = 8

onready var world = get_node("../../World")
onready var slot1 = get_node("../Hotbar/InventoryBtn")
onready var jAction = get_node("../Hotbar/J")
onready var kAction = get_node("../Hotbar/K")
onready var cursor = get_node("../../Cursor")
onready var crafting = get_node("../Crafting")

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
		inventoryToggle(false)
	if Input.is_action_just_pressed("Inventory"):
		inventoryToggle()
	if Input.is_action_just_pressed("background_toggle"):
		cursor.currentLayer = int(!bool(cursor.currentLayer))
		get_node("../Hotbar/BGT").texture.region.position = [Vector2(115,9),Vector2(0,0)][cursor.currentLayer]

func add_to_inventory(id : int,amount : int) -> void:
	$collect.play()
	if amount > 0:
		for item in range(inventory.size()):
			if inventory[item]["id"] == id:
				inventory[item]["amount"] += amount
				update_inventory()
				return
		inventory.append({"id":id,"amount":amount})
		update_inventory()

func remove_loc_from_inventory(loc : int) -> void:
	if loc < inventory.size():
		inventory.remove(loc)
		update_inventory()

func remove_id_from_inventory(id : int, amount : int) -> void:
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
		
		for item in range(1,inventory.size()):
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

#func update_inventory() -> void:
#	holding = false
#	holdingRef = -1
#	for child in $items.get_children():
#		child.queue_free()
#	if !find_item(jId).empty():
#		jRef = inventory.find(find_item(jId))
#	else:
#		jRef = -1
#		jId = 0
#	if !find_item(kId).empty():
#		kRef = inventory.find(find_item(kId))
#	else:
#		kRef = -1
#		kId = 0
#	if !inventory.empty():
#		slot1.show()
#		slot1.get_node("Amount").text = str(inventory[0]["amount"])
#		slot1.get_node("Item").texture = world.get_item_texture(inventory[0]["id"])
#		if jRef != -1:
#			jAction.get_node("Item").texture = world.get_item_texture(inventory[jRef]["id"])
#		else:
#			jAction.get_node("Item").texture = null
#		if kRef != -1:
#			kAction.get_node("Item").texture = world.get_item_texture(inventory[kRef]["id"])
#		else:
#			kAction.get_node("Item").texture = null
#		var page0 = Control.new()
#		page0.name = "0"
#		$items.add_child(page0)
#		var loc = 0
#		var x = 0
#		var y = 0
#		for item in range(1,inventory.size()):
#			if (item-1) % ITEM_PER_PAGE == 0:
#				var page = Control.new()
#				page.name = str((item-1) / ITEM_PER_PAGE)
#				$items.add_child(page)
#				loc = 0;x = 0;y = 0
#			var itemNode = INV_BTN.instance()
#			itemNode.rect_position = Vector2(x*50,y*16)
#			itemNode.loc = item
#			itemNode.get_node("Sprite").texture = world.get_item_texture(inventory[item]["id"])
#			itemNode.get_node("Amount").text = str(inventory[item]["amount"])
#			$items.get_node(str(int((item-1) / float(ITEM_PER_PAGE)))).add_child(itemNode)
#			loc += 1
#			x += 1
#			if x > 1:
#				x = 0;y += 1
#	else:
#		slot1.hide()
#	if currentPage > int((inventory.size()-2) / float(ITEM_PER_PAGE)):
#		currentPage = int((inventory.size()-2) / float(ITEM_PER_PAGE))
#	print("Item children")
#	for child in $items.get_children():
#		print(child.name)
#	update_buttons()
#	crafting.update_crafting()

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
	if loc != jRef and loc != kRef:
		if !holding:
			holding = true
			holdingRef = loc
			item.texture_normal = load("res://textures/GUI/main/inventory_holding.png")
		else:
			$change.play()
			var new = inventory[holdingRef].duplicate(true)
			inventory[holdingRef] = inventory[loc].duplicate(true)
			inventory[loc] = new
#			inventory.remove(loc)
#			inventory.push_front(new)
			update_inventory()

func inventoryToggle(toggle = true,setValue = false,mode = "inventory"):
	holding = false
	if toggle:
		setValue = !visible
	visible = setValue
	if visible:
		update_inventory()
	cursor.pause = setValue
	match mode:
		"inventory","crafting_table","oven","smithing_table":
			crafting.visible = setValue
			crafting.update_crafting(mode)

func inv_btn_action(location : int,action : String) -> void:
	var item = inventory[location]["id"]
	if world.itemData.has(item) and ["Tool"].has(world.itemData[item]["type"]):
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
		inventoryToggle()
	else:
		$change.play()
		var new = inventory[holdingRef].duplicate(true)
		inventory[holdingRef] = inventory[0].duplicate(true)
		inventory[0] = new
		update_inventory()

func _on_leftBtn_pressed():
	if currentPage > 0:
		currentPage -= 1
		update_buttons()

func _on_rightBtn_pressed():
	if currentPage < int(inventory.size()-2 / float(ITEM_PER_PAGE)):
		currentPage += 1
		update_buttons()
