extends Sprite2D

const WIRE = preload("res://assets/blocks/wire.tscn")

var REACH = 5

@onready var world = get_node("../World")
@onready var inventory: Control = $"../CanvasLayer/Inventory"
@onready var player = get_node("../Player")
@onready var effects: Node2D = $"../Effects"
@onready var sign_edit: Panel = $"../CanvasLayer/SignEdit"
@onready var main: Node2D = $".."
@onready var wire_hold: Node2D = $"../World/Wires"
@onready var entities: Node2D = $"../Entities"

var canPlace = true
var currentLayer = 1
var canInteract = false
var playerPos
var breaking = false

var currentShop = null

var cursorPos = Vector2(0,0)
var oldBlockPos = Vector2(0,0)

var wires : Array= [166]
var wireIn : Array = []
var pinsShown : bool = false
var wiring = false
var currentWire : TextureRect = null

func _process(_delta):
	if !get_tree().paused:
		if (inventory.inventory.size() > 0 and wires.has(inventory.inventory[0]["id"])) or (inventory.inventory.size() > 1 and wires.has(inventory.inventory[1]["id"])):
			if !pinsShown:
				pinsShown = true
				main.toggle_wire_visibility(true)
		elif pinsShown:
			pinsShown = false
			main.toggle_wire_visibility(false)
			wiring = false
			if is_instance_valid(currentWire):
				currentWire.queue_free()
				currentWire = null
		
		position = Vector2(int(snapped(get_global_mouse_position().x,world.BLOCK_SIZE.x)),int(snapped(get_global_mouse_position().y,world.BLOCK_SIZE.y)))
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
		
		blockPos = position / world.BLOCK_SIZE
		cursorPos = blockPos
		
		var blockAtPos : int = world.get_block_id(cursorPos,currentLayer)
		
		if (blockAtPos != 0 and GlobalData.blockData[blockAtPos]["interactable"]) or currentShop != null:
			texture = load("res://textures/GUI/main/interactable_cursor.png")
			canInteract = true
		else:
			texture = load("res://textures/GUI/main/cursor.png")
			canInteract = false
		
		if wiring:
			if is_instance_valid(currentWire):
				if currentWire.outputBlock != null:
					currentWire.position = currentWire.outputBlock.get_node("Outputs/" + currentWire.outputPin).global_position + currentWire.outputBlock.get_node("Outputs").offset + currentWire.wireOffset
				else:
					currentWire.position = currentWire.inputBlock.get_node("Inputs/" + currentWire.inputPin).global_position + currentWire.inputBlock.get_node("Inputs").offset + currentWire.wireOffset
				currentWire.rotation = currentWire.position.angle_to_point(get_global_mouse_position())
				currentWire.size.x = currentWire.position.distance_to(get_global_mouse_position())
			else:
				wiring = false
		
		if blockPos != oldBlockPos and breaking:
			stop_breaking()
		oldBlockPos = blockPos

func _unhandled_input(_event):
	if !wiring and !get_tree().paused and cursorPos.x < world.worldSize.x and cursorPos.x >= 0 and cursorPos.y < world.worldSize.y and cursorPos.y >= 0:
		if Input.is_action_pressed("build") or Input.is_action_pressed("build2"):
			if currentShop != null: #Tests if cursor is in a shop
				match currentShop.id:
					139:
						inventory.inventoryToggle(false,true,"lily_mart")
					141:
						inventory.inventoryToggle(false,true,"skips_stones")
			elif canInteract and world.worldRules["interact_with_blocks"]["value"] and (Input.is_action_just_pressed("build") or Input.is_action_just_pressed("build2")):
				var currentBlock : BaseBlock = world.get_block(cursorPos,currentLayer)
				match currentBlock.id:
					12,158:
						inventory.inventoryToggle(false,true,"crafting_table")
					16:
						inventory.inventoryToggle(false,true,"oven")
					28:
						inventory.inventoryToggle(false,true,"smithing_table")
					91,159:
						inventory.inventoryToggle(false,true,"chest")
					145:
						var sign = currentBlock
						if !sign.data["locked"]:
							sign_edit.pop_up(sign)
						elif sign.data["mode"] == "Click":
							main.display_text(sign.data)
					167:
						currentBlock.flip_lever()
					169:
						$"../CanvasLayer/LogicBlockEdit".pop_up(currentBlock)
					171,301:
						if currentBlock is GhostBlock:
							world.get_block(currentBlock.mainBlockLoc,currentBlock.layer).interact()
						else:
							currentBlock.interact()
					176:
						currentBlock.pressed_btn()
					186:
						$"../CanvasLayer/StructureSaveEdit".pop_up(currentBlock)
					189:
						$"../CanvasLayer/LineEditPopUp".pop_up(currentBlock,"Dev chest")
					185:
						$"../CanvasLayer/LineEditPopUp".pop_up(currentBlock,"Link block")
					216:
						inventory.inventoryToggle(false,true,"upgrade_table")
					241:
						$"../CanvasLayer/MusicPlayer".currentMusicPlayer = currentBlock
						inventory.inventoryToggle(false,true,"music_player")
					243:
						$"../CanvasLayer/SliderPopUp".pop_up(currentBlock)
					244:
						if currentBlock.pos == Vector2(94,55) and Global.currentSystemId + "_"+ str(Global.currentPlanet) == "2340163271682_1":
							entities.summon_entity("mini_transporter",(currentBlock.pos+Vector2(0,2)) * 8)
						else:
							inventory.add_to_inventory(244,1)
						world.set_block(currentBlock.pos, currentLayer, 0, true)
					246:
						var slot = {true:0,false:1}[Input.is_action_pressed("build")]
						if inventory.inventory.size() > slot:
							match inventory.inventory[slot]["id"]:
								191:
									if currentBlock.data["magma"] < 3:
										currentBlock.data["magma"] += 1
										currentBlock.updated_data()
										inventory.remove_amount_at_loc(slot,1)
									elif currentBlock.data["coolant"] >= 3:
										currentBlock.data["active"] = !currentBlock.data["active"]
										currentBlock.updated_data()
										if currentBlock.data["active"]:
											$"../CanvasLayer/TeleportPrompt".show()
								205:
									if currentBlock.data["coolant"] < 3:
										currentBlock.data["coolant"] += 1
										currentBlock.updated_data()
										inventory.remove_amount_at_loc(slot,1)
									elif currentBlock.data["magma"] >= 3:
										currentBlock.data["active"] = !currentBlock.data["active"]
										currentBlock.updated_data()
										if currentBlock.data["active"]:
											$"../CanvasLayer/TeleportPrompt".show()
								_:
									if currentBlock.data["magma"] >= 3 and currentBlock.data["coolant"] >= 3:
										currentBlock.data["active"] = !currentBlock.data["active"]
										currentBlock.updated_data()
										if currentBlock.data["active"]:
											$"../CanvasLayer/TeleportPrompt".show()
					263:
						inventory.inventoryToggle(false,true,"wool_work_table")
					320:
						inventory.inventoryToggle(false,true,"cooking_pot")
					328:
						inventory.inventoryToggle(false,true,"tech_workbench")
			elif Input.is_action_just_pressed("build2") and wireIn.size() > 0:
				if is_instance_valid(wireIn[0]):
					wireIn[0].break_wire()
					await get_tree().process_frame
				else:
					wireIn.remove_at(0)
			elif (Input.is_action_pressed("build") and inventory.inventory.size() > 0) or (Input.is_action_pressed("build2") and inventory.inventory.size() > 1):
				var slot = 0 if Input.is_action_pressed("build") or inventory.inventory.size() < 2 else 1
				var selectedId = inventory.inventory[slot]["id"]
				if (currentLayer == 0 or canPlace) and GlobalData.blockData.has(selectedId) and world.worldRules["place_blocks"]["value"]:
					world.build_event("Build",cursorPos,currentLayer,selectedId)#Vector2(int(position.x),int(position.y)),1,inventory.inventory[0]["id"])
				elif GlobalData.itemData.has(selectedId):
					tool_action(selectedId,slot)
		elif Input.is_action_pressed("action1") or Input.is_action_pressed("action2"):
			var ref = inventory.jRef	if Input.is_action_pressed("action1") else inventory.kRef
			if ref != -1:
				tool_action(inventory.inventory[ref]["id"],ref)
		elif breaking:
			stop_breaking()
	elif wiring and !get_tree().paused:
		if Input.is_action_just_pressed("build2"):
			wiring = false
			if is_instance_valid(currentWire):
				currentWire.queue_free()
				currentWire = null

func tool_action(itemId : int, ref := 0) -> void:
	var itemSelect = GlobalData.itemData[itemId]
	match itemSelect["type"]:
		"Bucket","Watering_can":
			if world.get_block_id(cursorPos,currentLayer) == 117 and world.worldRules["break_blocks"]["value"]:
				var water = world.get_block(cursorPos,currentLayer)
				#if inventory.inventory[ref]["data"].has("water_level"):
				var bucketWaterLevel = inventory.inventory[ref]["data"]["water_level"]
				if bucketWaterLevel + water.data["water_level"] < 4:
					inventory.add_to_inventory(itemId,1,true,{"water_level":bucketWaterLevel + water.data["water_level"]})
					inventory.remove_amount_at_loc(ref,1)
					world.set_block(cursorPos,currentLayer,0,true)
				else:
					water.data["water_level"] -= 4 - bucketWaterLevel
					if water.data["water_level"] <= 0:
						world.set_block(cursorPos,currentLayer,0,true)
					water.update_water_texture()
					water.on_update()
					inventory.add_to_inventory(itemId,1,true,{"water_level":4})
					inventory.remove_amount_at_loc(ref,1)
				#else:
					#inventory.inventory[ref]["data"] = {"water_level":water.data["water_level"]}
					#world.set_block(cursorPos,currentLayer,0,true)
			elif itemSelect["type"] != "Watering_can" and currentLayer != 0 and world.get_block_id(cursorPos,currentLayer) == 0 and world.worldRules["place_blocks"]["value"] and inventory.inventory[ref]["data"].has("water_level") and inventory.inventory[ref]["data"]["water_level"] > 0: #places water
				world.set_block(cursorPos,currentLayer,117,true,{"water_level":inventory.inventory[ref]["data"]["water_level"]})
				inventory.add_to_inventory(itemId,1,true,{"water_level":0})
				inventory.remove_amount_at_loc(ref,1)
			elif itemSelect["type"] == "Watering_can" and inventory.inventory[ref]["data"].has("water_level") and inventory.inventory[ref]["data"]["water_level"] > 0:
				$"../Effects".spray(player.position,player.flipped)
				inventory.inventory[ref]["data"]["water_level"] -= 0.25
			inventory.update_inventory()
		"Full_bucket": #Used for godmode
			if world.worldRules["place_blocks"]["value"]:
				var blockAtPos = world.get_block(cursorPos,currentLayer)
				if blockAtPos == null and currentLayer != 0:
					world.set_block(cursorPos,currentLayer,117,true,{"water_level":4})
				elif blockAtPos != null and blockAtPos.id == 117:
					blockAtPos.data["water_level"] = 4
					blockAtPos.update_water_texture()
					blockAtPos.on_update()
		"tool":
			if !breaking and world.get_block_id(cursorPos,currentLayer) > 0 and itemSelect["strength"] >= GlobalData.blockData[world.get_block_id(cursorPos,currentLayer)]["canHaverst"] and (world.worldRules["break_blocks"]["value"] or (world.get_block_id(cursorPos,currentLayer) == 8)):
				var hardness = GlobalData.blockData[world.get_block_id(cursorPos,currentLayer)]["hardness"]
				if hardness <= 0:
					world.build_event("Break",position / world.BLOCK_SIZE,currentLayer)
				else:
					var speedModifier = itemSelect["speed"]
					if get_item_upgrades(inventory.inventory[ref]).has("speed"):
						speedModifier += get_item_upgrades(inventory.inventory[ref])["speed"] * max(1,itemSelect["speed"]/2.0)
					$break/AnimationPlayer.speed_scale = (1 / float(hardness)) * speedModifier
					$break/AnimationPlayer.play("break")
					_on_break_sound_timer_timeout()
					$BreakSoundTimer.start()
					breaking = true
		"Hoe":
			if [1,2].has(world.get_block_id(cursorPos,currentLayer)):
				world.set_block(cursorPos,currentLayer,119,true)
		"Food":
			if player.health < player.maxHealth:
				inventory.remove_amount_at_loc(ref,1)
				player.health += itemSelect["regen"]
				effects.floating_text(player.position, "+" + str(itemSelect["regen"]), Color.GREEN)
		"cooked_food":
			if player.health < player.maxHealth:
				var regen : int = inventory.inventory[ref]["data"]["regen"]
				player.health = min(player.maxHealth,player.health + regen)
				inventory.remove_amount_at_loc(ref,1)
				effects.floating_text(player.position, "+" + str(regen), Color.GREEN)

func get_item_upgrades(itemData : Dictionary) -> Dictionary:
	var upgrades : Dictionary
	if itemData["data"].has("upgrades"):
		for slot : String in itemData["data"]["upgrades"]:
			if upgrades.has(itemData["data"]["upgrades"][slot]):
				upgrades[itemData["data"]["upgrades"][slot]] += 1
			else:
				upgrades[itemData["data"]["upgrades"][slot]] = 1
	return upgrades

func stop_breaking():
	breaking = false
	$BreakSoundTimer.stop()
	$break/AnimationPlayer.play("RESET")

func _on_playerTest_body_entered(_body):
	canPlace = false

func _on_playerTest_body_exited(_body):
	canPlace = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "break" and breaking:
		breaking = false
		$break/AnimationPlayer.play("RESET")
		$BreakSoundTimer.stop()
		GlobalGui.complete_achievement("One small step")
		world.build_event("Break",cursorPos,currentLayer)

func _on_ShopTest_body_entered(body):
	currentShop = body

func _on_ShopTest_body_exited(body):
	if body == currentShop:
		currentShop = null

func _on_main_output_pressed(logicBlock : LogicBlock, pin : String) -> void:
	if currentWire == null:
		wiring = true
		var wire = WIRE.instantiate()
		currentWire = wire
		wire.outputBlock = logicBlock
		wire.outputPin = pin
		wire_hold.add_child(wire)
	elif currentWire.outputBlock == null:
		wiring = false
		currentWire.outputBlock = logicBlock
		currentWire.outputPin = pin
		var good = true
		for wireObj in wire_hold.get_children():
			if wireObj != currentWire and wireObj.outputBlock == logicBlock and wireObj.outputPin == pin and wireObj.inputBlock == currentWire.inputBlock and wireObj.inputPin == currentWire.inputPin:
				currentWire.queue_free()
				wireObj.break_wire()
				currentWire = null
				good = false
				break
		if good:
			currentWire.setup()
			currentWire = null

func _on_main_input_pressed(logicBlock : LogicBlock, pin : String) -> void:
	if currentWire == null:
		wiring = true
		var wire = WIRE.instantiate()
		currentWire = wire
		wire.inputBlock = logicBlock
		wire.inputPin = pin
		wire_hold.add_child(wire)
	elif currentWire.inputBlock == null:
		wiring = false
		currentWire.inputBlock = logicBlock
		currentWire.inputPin = pin
		var good = true
		for wireObj in wire_hold.get_children():
			if wireObj != currentWire and wireObj.inputBlock == logicBlock and wireObj.inputPin == pin and wireObj.outputBlock == currentWire.outputBlock and wireObj.outputPin == currentWire.outputPin:
				currentWire.queue_free()
				wireObj.break_wire()
				currentWire = null
				good = false
				break
		if good:
			currentWire.setup()
			currentWire = null

func _on_break_sound_timer_timeout() -> void:
	GlobalAudio.play_block_audio_2d(world.get_block_id(cursorPos,currentLayer),"step",position)
