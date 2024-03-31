extends Sprite

var REACH = 5

onready var world = get_node("../World")
onready var inventory = get_node("../CanvasLayer/Inventory")
onready var player = get_node("../Player")

var canPlace = true
var currentLayer = 1
var canInteract = false
var playerPos
var breaking = false

var currentShop = null

var cursorPos = Vector2(0,0)
var oldBlockPos = Vector2(0,0)

func _process(_delta):
	if !Global.pause:
		position = Vector2(int(stepify(get_global_mouse_position().x,world.BLOCK_SIZE.x)),int(stepify(get_global_mouse_position().y,world.BLOCK_SIZE.y)))
		playerPos = Vector2(int(player.position.x/ world.BLOCK_SIZE.x),int((player.position.y+2)/ world.BLOCK_SIZE.y))
		var blockPos = position / world.BLOCK_SIZE
		if Global.godmode:
			REACH = 10
		else:
			REACH = 5
		if blockPos.x < playerPos.x - REACH:
			position.x = (playerPos.x - REACH)*world.BLOCK_SIZE.x
		if blockPos.x < 0:
			position.x = 0
		
		if blockPos.x > playerPos.x + REACH-1:
			position.x = (playerPos.x + REACH-1)* world.BLOCK_SIZE.x
		elif blockPos.x > world.worldSize.x-1:
			position.x = (world.worldSize.x-1)*world.BLOCK_SIZE.x
		
		if blockPos.y < playerPos.y - REACH:
			position.y = (playerPos.y - REACH)*world.BLOCK_SIZE.y
		elif blockPos.y < 0:
			position.y = 0
		
		if blockPos.y > playerPos.y + REACH-1:
			position.y = (playerPos.y + REACH-1)*world.BLOCK_SIZE.y
		elif blockPos.y > world.worldSize.y-1 :
			position.y = (world.worldSize.y-1)*world.BLOCK_SIZE.y
		
		if world.interactableBlocks.has(world.get_block_id(position / world.BLOCK_SIZE,currentLayer)) or currentShop != null:
			texture = load("res://textures/GUI/main/interactable_cursor.png")
			canInteract = true
		else:
			texture = load("res://textures/GUI/main/cursor.png")
			canInteract = false
		
		blockPos = position / world.BLOCK_SIZE
		cursorPos = blockPos
		if blockPos != oldBlockPos and breaking:
			stop_breaking()
		oldBlockPos = blockPos

func _unhandled_input(_event):
	if !Global.pause and cursorPos.x < world.worldSize.x and cursorPos.x >= 0 and cursorPos.y < world.worldSize.y and cursorPos.y >= 0:
		if Input.is_action_pressed("build") or Input.is_action_pressed("build2"):
			if currentShop != null:
				print("in a shop")
				match currentShop.id:
					139:
						inventory.inventoryToggle(false,true,"lily_mart")
					141:
						inventory.inventoryToggle(false,true,"skips_stones")
			elif canInteract and world.worldRules["interact_with_blocks"]["value"]:
				match world.get_block_id(cursorPos,currentLayer):
					12:
						inventory.inventoryToggle(false,true,"crafting_table")
					16:
						inventory.inventoryToggle(false,true,"oven")
					28:
						inventory.inventoryToggle(false,true,"smithing_table")
					91:
						inventory.inventoryToggle(false,true,"chest")
			elif (Input.is_action_pressed("build") and inventory.inventory.size() > 0) or (Input.is_action_pressed("build2") and inventory.inventory.size() > 1):
				var slot = 0 if Input.is_action_pressed("build") or inventory.inventory.size() < 2 else 1
				var selectedId = inventory.inventory[slot]["id"]
				if (currentLayer == 0 or canPlace) and world.blockData.has(selectedId) and world.worldRules["place_blocks"]["value"]:
					world.build_event("Build",cursorPos,currentLayer,selectedId)#Vector2(int(position.x),int(position.y)),1,inventory.inventory[0]["id"])
				elif world.itemData.has(selectedId):
					tool_action(selectedId,slot)
		elif Input.is_action_pressed("action1") or Input.is_action_pressed("action2"):
			var ref = inventory.jRef
			if Input.is_action_pressed("action2"):
				ref = inventory.kRef
			if ref != -1:
				tool_action(inventory.inventory[ref]["id"],ref)
		elif breaking:
			stop_breaking()

func tool_action(itemId : int, ref := 0) -> void:
	var itemSelect = world.itemData[itemId]
	match itemSelect["type"]:
		"Bucket","Watering_can":
			if world.get_block_id(cursorPos,currentLayer) == 117 and world.worldRules["break_blocks"]["value"]:
				var water = world.get_block(cursorPos,currentLayer)
				if inventory.inventory[ref].has("data") and inventory.inventory[ref]["data"].has("water"):
					var bucketWaterLevel = inventory.inventory[ref]["data"]["water"]
					if bucketWaterLevel + water.data["water_level"] < 4:
						inventory.inventory[ref]["data"]["water"] += water.data["water_level"]
						world.set_block(cursorPos,currentLayer,0,true)
					else:
						water.data["water_level"] -= 4 - bucketWaterLevel
						if water.data["water_level"] <= 0:
							world.set_block(cursorPos,currentLayer,0,true)
						water.update_water_texture()
						water.on_update()
						inventory.inventory[ref]["data"]["water"] = 4
				else:
					inventory.inventory[ref]["data"] = {"water":water.data["water_level"]}
					world.set_block(cursorPos,currentLayer,0,true)
			elif itemSelect["type"] != "Watering_can" and world.worldRules["place_blocks"]["value"] and inventory.inventory[ref].has("data") and inventory.inventory[ref]["data"].has("water") and inventory.inventory[ref]["data"]["water"] > 0:
				world.set_block(cursorPos,currentLayer,117,true,{"water_level":inventory.inventory[ref]["data"]["water"]})
				inventory.inventory[ref]["data"]["water"] = 0
			elif itemSelect["type"] == "Watering_can" and inventory.inventory[ref].has("data") and inventory.inventory[ref]["data"].has("water") and inventory.inventory[ref]["data"]["water"] > 0:
				$"../Effects".spray(player.position,player.flipped)
				inventory.inventory[ref]["data"]["water"] -= 0.25
			inventory.update_inventory()
		"Tool":
			if !breaking and world.get_block_id(cursorPos,currentLayer) > 0 and world.blockData[world.get_block_id(cursorPos,currentLayer)]["breakWith"] != "None" and itemSelect["strength"] >= world.blockData[world.get_block_id(cursorPos,currentLayer)]["canHaverst"] and world.worldRules["break_blocks"]["value"]:
				var hardness = world.blockData[world.get_block_id(cursorPos,currentLayer)]["hardness"]
				if hardness <= 0:
					world.build_event("Break",position / world.BLOCK_SIZE,currentLayer)
				else:
					$break/AnimationPlayer.playback_speed = (1 / float(hardness)) * itemSelect["speed"]
					$break/AnimationPlayer.play("break")
					breaking = true
		"Hoe":
			if [1,2].has(world.get_block_id(cursorPos,currentLayer)):
				world.set_block(cursorPos,currentLayer,119,true)

func stop_breaking():
	breaking = false
	$break/AnimationPlayer.play("RESET")

func _on_playerTest_body_entered(_body):
	canPlace = false

func _on_playerTest_body_exited(_body):
	canPlace = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "break" and breaking:
		breaking = false
		$break/AnimationPlayer.play("RESET")
		GlobalGui.complete_achievement("One small step")
		world.build_event("Break",position / world.BLOCK_SIZE,currentLayer)

func _on_ShopTest_body_entered(body):
	currentShop = body

func _on_ShopTest_body_exited(body):
	if body == currentShop:
		currentShop = null
