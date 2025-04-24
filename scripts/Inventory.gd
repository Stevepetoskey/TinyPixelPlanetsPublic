extends Control

const BACKGROUND_TEXTURE = preload("res://textures/GUI/main/hotbar/background.png")
const FOREGROUND_TEXTURE = preload("res://textures/GUI/main/hotbar/forground.png")
const INV_BTN = preload("res://assets/InventoryBtn.tscn")
const ITEM_PER_PAGE = 8
var INVENTORY_SIZE = 20
const ITEM_STACK_SIZE = 99

@onready var main: Node2D = $"../.."
@onready var world = get_node("../../World")
@onready var slot1: TextureButton = $"../Hotbar/InventoryBtn"
@onready var slot2: TextureButton = $"../Hotbar/InventoryBtn2"
@onready var jAction = get_node("../Hotbar/J")
@onready var kAction = get_node("../Hotbar/K")
@onready var cursor = get_node("../../Cursor")
@onready var crafting = get_node("../Crafting")
@onready var chest = get_node("../Chest")
@onready var entities = $"../../Entities"
@onready var item_container = $ItemScroll/ItemContainer
@onready var shop: Control = $"../Shop"
@onready var godmode: Control = $"../Godmode"
@onready var upgrade: Control = $"../Upgrade"
@onready var music_player: Control = $"../MusicPlayer"
@onready var cooking_pot: Control = $"../CookingPot"
@onready var transfer_ui: NinePatchRect = $TransferUI

var blockTutorials : Dictionary = {12:"crafting_table",16:"oven",28:"smithing_table",30:"platforms",91:"chests",159:"chests",121:"seeds",122:"seeds",123:"seeds",221:"seeds",145:"signs",167:"lever",168:"display_block",169:"logic_block",170:"flip_block",171:"doors",172:"doors",301:"doors",176:"button",216:"upgrade_table",241:"music_player",243:"timer_block",246:"endgame_locator",263:"wool_work_table"}
var itemTutorials : Dictionary = {113:"buckets",114:"buckets",115:"buckets",116:"buckets",129:"hoes",130:"hoes",131:"watering_cans",132:"watering_cans",166:"wires",191:"magma_ball",205:"coolant_shard",215:"upgrade_module",238:"music_chips",239:"music_chips",240:"music_chips"}
#{"id":int,"amount":int,"data":dictionary}
var inventory : Array = []
var jRef : int = -1 #Where the j reference is located in inventory
var kRef : int = -1
var jId : int = 0
var kId : int = 0
var deleteHold : Dictionary = {}

var holding : bool = false
var holdingRef : int = -1

signal gained_item
signal opened_inventory

func _ready() -> void:
	for slot : TextureButton in [slot1,slot2]:
		slot.mouse_entered.connect(mouse_in_btn.bind({slot1:0,slot2:1}[slot]))
		slot.mouse_exited.connect(mouse_out_btn)
	update_inventory()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and visible:
		await get_tree().process_frame
		inventoryToggle(false,false,"close")
	if Input.is_action_just_pressed("inventory") and (!get_tree().paused or visible):
		inventoryToggle()
	if Input.is_action_just_pressed("background_toggle") and !get_tree().paused:
		cursor.currentLayer = int(!bool(cursor.currentLayer))
		$"../Hotbar/HBoxContainer/BGT".texture = [BACKGROUND_TEXTURE,FOREGROUND_TEXTURE][cursor.currentLayer]

func add_to_inventory(id : int,amount : int,drop : bool = true,data := {}) -> Dictionary:
	print("data added: ",data)
	gained_item.emit(id)
	check_tutorial(id)
	match id: #For achievements
		31:
			GlobalGui.complete_achievement("An upgrade")
		98:
			GlobalGui.complete_achievement("Top of the line")
		205:
			GlobalGui.complete_achievement("Into ice")
		191:
			GlobalGui.complete_achievement("Into lava")
		246:
			GlobalGui.complete_achievement("Location needed")
	if GlobalData.get_item_data(id).has("type") and GlobalData.get_item_data(id)["type"] == "weapon":
		GlobalGui.complete_achievement("Ready for battle")
	GlobalAudio.play_sound_effect("Game/collect_item.ogg")
	if amount > 0:
		var itemData = GlobalData.get_item_data(id)
		if itemData.has("starter_data") and data.is_empty():
			data = itemData["starter_data"].duplicate(true)
		if ["weapon","tool","armor"].has(itemData["type"]) and !data.has("upgrades"):
			data["upgrades"] = {"left":"","top":"","right":""}
		var stackSize = ITEM_STACK_SIZE if !itemData.has("stack_size") else itemData["stack_size"]
		for item in range(inventory.size()):
			if inventory[item]["id"] == id and inventory[item]["data"] == data:
				if inventory[item]["amount"] + amount <= stackSize:
					inventory[item]["amount"] += amount
					amount = 0
				else:
					amount -= stackSize - inventory[item]["amount"]
					inventory[item]["amount"] = stackSize
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
				if amount > stackSize:
					newAmount = stackSize
				inventory.append({"id":id,"amount":newAmount,"data":data})
				amount -= stackSize
	update_inventory()
	return {}

func check_tutorial(itemId : int) -> void:
	var tutorial : String = "blocks"
	var subTutorial : String = "crafting_table"
	if blockTutorials.has(itemId):
		subTutorial = blockTutorials[itemId]
	elif itemTutorials.has(itemId):
		tutorial = "items"
		subTutorial = itemTutorials[itemId]
	else:
		return
	GlobalGui.display_tutorial(tutorial,subTutorial,"right",true)

func insert_item_in_inventory(loc : int,item : Dictionary) -> void:
	if loc < inventory.size():
		if loc <= jRef:
			jRef += 1
		if loc <= kRef:
			kRef += 1
		inventory.insert(loc,item)
	else:
		inventory.append(item)

func remove_loc_from_inventory(loc : int) -> void:
	if loc < inventory.size():
		if loc < jRef:
			jRef -= 1
		elif loc == jRef:
			jRef = -1
			jId = 0
		if loc < kRef:
			kRef -= 1
		elif loc == kRef:
			kRef = -1
			kId = 0
		inventory.remove_at(loc)
		update_inventory()

func remove_amount_at_loc(loc : int,amount : int) -> void:
	if loc < inventory.size() and !Global.godmode:
		inventory[loc]["amount"] -= amount
		print("removed!")
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
	$ClearBtn.visible = Global.godmode
	$Blues/Label.text = "*" + str(Global.blues)
	
	holding = false
	holdingRef = -1
	
	#Gets j and k refs
	#if !find_item(jId).is_empty():
		#jRef = inventory.find(find_item(jId))
	#else:
		#jRef = -1
		#jId = 0
	#if !find_item(kId).is_empty():
		#kRef = inventory.find(find_item(kId))
	#else:
		#kRef = -1
		#kId = 0
	
	#clears all items
	for item in item_container.get_children():
		item.queue_free()
	
	if !inventory.is_empty():
		#Sets first slot's texture
		slot1.show()
		slot1.get_node("Amount").text = str(inventory[0]["amount"])
		slot1.get_node("Item").set_item(inventory[0])
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
			slot2.get_node("Item").set_item(inventory[1])
			if jRef == 1:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_j.png")
			elif kRef == 1:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_k.png")
			else:
				slot2.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2.png")
		else:
			slot2.hide()
		
		#Sets J and K ref's texture
		if jRef < inventory.size():
			if jRef != -1:
				jAction.get_node("Item").set_item(inventory[jRef])
			else:
				jAction.get_node("Item").texture = null
		else:
			jRef = -1
		if kRef < inventory.size():
			if kRef != -1:
				kAction.get_node("Item").set_item(inventory[kRef])
			else:
				kAction.get_node("Item").texture = null
		else:
			kRef = -1
		
		#Creates items
		for itemLoc in range(2,inventory.size()):
			var itemNode = INV_BTN.instantiate()
			itemNode.loc = itemLoc
			itemNode.get_node("ItemGUI").set_item(inventory[itemLoc])
			itemNode.get_node("Amount").text = str(inventory[itemLoc]["amount"])
			item_container.add_child(itemNode)
	else:
		slot1.hide()
		slot2.hide()
		jAction.get_node("Item").texture = null
		kAction.get_node("Item").texture = null
	crafting.update_crafting()

func transfer_items(itemData : Dictionary, to : String, loc : int) -> void:
	match to:
		"chest":
			if jRef == loc:
				jId = 0
				jRef = -1
			if kRef == loc:
				kId = 0
				kRef = -1
			var leftover = chest.add_to_chest(itemData["id"],itemData["amount"],itemData["data"])
			inventory[loc]["amount"] -= itemData["amount"]
			if inventory[loc]["amount"] <= 0:
				remove_loc_from_inventory(loc)
			if leftover.is_empty():
				update_inventory()
				chest.update_chest()
			else:
				add_to_inventory(leftover["id"],leftover["amount"],true,leftover["data"])
		"inventory":
			var leftover = add_to_inventory(itemData["id"],itemData["amount"],true,itemData["data"])
			transfer_ui.finished_transfer(leftover)
			update_inventory()
		"cooking_pot_fuel":
			print("Sending item: ",itemData)
			var leftover : int = 0
			cooking_pot.currentPot.data["fuel"]["id"] = itemData["id"]
			if cooking_pot.currentPot.data["fuel"]["amount"] + itemData["amount"] <= GlobalData.get_item_stack_size(itemData["id"]):
				cooking_pot.currentPot.data["fuel"]["amount"] += itemData["amount"]
			else:
				leftover = cooking_pot.currentPot.data["fuel"]["amount"] + itemData["amount"] - GlobalData.get_item_stack_size(itemData["id"])
			inventory[loc]["amount"] -= itemData["amount"] - leftover
			if inventory[loc]["amount"] <= 0:
				remove_loc_from_inventory(loc)
			update_inventory()
			cooking_pot.update_textures()

func btn_clicked(loc : int, item : TextureButton) -> void:
	if !transfer_ui.visible and visible:
		if chest.visible:
			transfer_ui.begin_transfer(inventory[loc],"chest",loc)
		elif cooking_pot.visible:
			if cooking_pot.fuel.has(inventory[loc]["id"]) and [0,inventory[loc]["id"]].has(cooking_pot.currentPot.data["fuel"]["id"]):
				transfer_ui.begin_transfer(inventory[loc],"cooking_pot_fuel",loc)
			elif cooking_pot.ingredients.has(inventory[loc]["id"]) and cooking_pot.add_to_pot(inventory[loc]):
				remove_amount_at_loc(loc,1)
		else:
			if !holding:
				holding = true
				holdingRef = loc
				match item:
					slot1:
						item.texture_normal = load("res://textures/GUI/main/hotbar/hotbar1_selected.png")
					slot2:
						item.texture_normal = load("res://textures/GUI/main/hotbar/hotbar2_selected.png")
					_:
						item.texture_normal = load("res://textures/GUI/main/inventory/inventory_holding.png")
			else:
				GlobalAudio.play_sound_effect("GUI/inventory.ogg")
				var new = inventory[holdingRef].duplicate(true)
				if holdingRef == jRef:
					jRef = loc
				elif holdingRef == kRef:
					kRef = loc
				elif loc == jRef:
					jRef = holdingRef
				elif loc == kRef:
					kRef = holdingRef
				inventory[holdingRef] = inventory[loc].duplicate(true)
				inventory[loc] = new
				update_inventory()

func inv_btn_clicked(loc : int,item : TextureButton):
	btn_clicked(loc,item)

func mouse_in_btn(loc : int):
	if inventory.size() > loc and visible:
		$"../ItemData".display(inventory[loc])

func mouse_out_btn():
	$"../ItemData".hide()

func inventoryToggle(toggle = true,setValue = false,mode = "inventory"):
	GlobalGui.close_ach()
	$"../ItemData".hide()
	transfer_ui.hide()
	holding = false
	if toggle:
		setValue = !visible
		if !setValue:
			mode = "close"
	visible = setValue
	get_tree().paused = setValue
	if visible:
		update_inventory()
	match mode:
		"close":
			crafting.close()
			chest.hide()
			shop.hide()
			godmode.hide()
			upgrade.clear()
			music_player.hide()
			cooking_pot.clear()
		"inventory","crafting_table","oven","smithing_table","wool_work_table","tech_workbench":
			opened_inventory.emit()
			if !Global.godmode or mode != "inventory":
				crafting.visible = setValue
				crafting.update_crafting(mode)
			else:
				godmode.pop_up(setValue)
		"upgrade_table":
			upgrade.pop_up()
		"music_player":
			music_player.pop_up()
		"chest":
			print("hide chest: ",setValue)
			chest.visible = setValue
			chest.update_chest(world.get_block(cursor.cursorPos,cursor.currentLayer))
		"lily_mart","skips_stones":
			shop.pop_up(mode)
		"cooking_pot":
			cooking_pot.currentPot = world.get_block(cursor.cursorPos,cursor.currentLayer)
			cooking_pot.pop_up()

func inv_btn_action(location : int,action : String) -> void:
	var item = inventory[location]["id"]
	if GlobalData.itemData.has(item) and ["tool","weapon","Hoe"].has(GlobalData.itemData[item]["type"]):
		GlobalAudio.play_sound_effect("GUI/equip.ogg")
		match action:
			"j":
				if jRef == location:
					jRef = -1
					jId = 0
				elif kRef != location:
					jRef = location
					jId = item
			"k":
				if kRef == location:
					kRef = -1
					kId = 0
				elif jRef != location:
					kRef = location
					kId = item
	update_inventory()

func _on_InventoryBtn_pressed():
	btn_clicked(0,slot1)

func _on_InventoryBtn2_pressed():
	btn_clicked(1,slot2)

func _on_clear_btn_pressed() -> void:
	inventory = []
	jRef = -1
	kRef = -1
	update_inventory()

func _on_delete_item_btn_pressed() -> void:
	if holding:
		deleteHold = inventory[holdingRef].duplicate(true)
		remove_loc_from_inventory(holdingRef)
