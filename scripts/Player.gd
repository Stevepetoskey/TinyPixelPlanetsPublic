extends CharacterBody2D
class_name Player

const GRAVITY = 4
const ACCEL = 8
const MAX_SPEED = 45
const SPRINT_SPEED = 70
const FRICTION = 4
const JUMPSPEED = 75

#Collision
const DEFAULT_LAYER = 517
const NO_PLATFORM = 513

@onready var cursor = get_node("../Cursor")
@onready var armor = get_node("../CanvasLayer/Inventory/Armor")
@onready var effects = get_node("../Effects")
@onready var inventory = get_node("../CanvasLayer/Inventory")
@onready var world = get_node("../World")
@onready var entities = get_node("../Entities")
@onready var main: Node2D = $".."
@onready var swing_timer: Timer = $SwingTimer
@onready var textures: Node2D = $Textures
@onready var clothes: Node2D = $Textures/Clothes
@onready var player_animations: AnimationPlayer = $Textures/AnimationPlayer


var type = "player"
var coyote = true
var timerOn = false
var jumping = false
var swinging : bool = false
var swingingWith : int = 0
var currentBlocksOn : Array = []
var currentBlocksOnHead : Array = []
var canBreath : bool = true
var currentTemp : int = 0
var flying = false
var defPoints = 0
var inWater = false
var frozen : bool = false
var poisoned : bool = false
var armorBuff : String = ""
var jetpackLevel : int = 0
var jetpackFuel : int = 0
var usingJetpack : bool = false
var movementModifier : int = 0
var knockedBack : bool = false
var inControl : bool = true
var createBubble : bool = true
var underWater : bool = false
var currentWearing : Dictionary

var eyeTexture : ImageTexture

var dead = false
var flipped = false

var toAttack = []

var maxHealth = 50
var health = 50

var maxOxygen = 50
var oxygen = 50
var suitOxygen = 500
var suitOxygenMax = 500

var gender = "male"

var clothesSpritesheets : Dictionary = {
	46:{"name":"space","contains":["head"]},
	47:{"name":"space","contains":["left_arm","right_arm","torso"]},
	48:{"name":"space","contains":["left_leg","right_leg"]},
	49:{"name":"space","contains":["shoes"]},
	35:{"name":"copper","contains":["head"]},
	36:{"name":"copper","contains":["left_arm","right_arm","torso"]},
	37:{"name":"copper","contains":["left_leg","right_leg"]},
	38:{"name":"copper","contains":["shoes"]},
	39:{"name":"silver","contains":["head"]},
	40:{"name":"silver","contains":["left_arm","right_arm","torso"]},
	41:{"name":"silver","contains":["left_leg","right_leg"]},
	42:{"name":"silver","contains":["shoes"]},
	211:{"name":"fire","contains":["head"]},
	212:{"name":"fire","contains":["left_arm","right_arm","torso"]},
	213:{"name":"fire","contains":["left_leg","right_leg"]},
	214:{"name":"fire","contains":["shoes"]},
	207:{"name":"coat","contains":["head"]},
	208:{"name":"coat","contains":["left_arm","right_arm","torso"]},
	209:{"name":"coat","contains":["left_leg","right_leg"]},
	210:{"name":"coat","contains":["shoes"]},
}

func _ready():
	update_character()
	if health < 0:
		dead = true
		effects.death_particles(position)
		hide()
		get_node("../CanvasLayer/Dead").popup()
	_on_Armor_updated_armor(armor.armor)

func _physics_process(_delta):
	if !dead and !frozen:
		#Swinging process
		if inventory.inventory.size() > 0:
			if Input.is_action_pressed("build"):
				swing(0)
				#swing(inventory.inventory[0]["id"])
			elif Input.is_action_pressed("build2") and inventory.inventory.size() > 1:
				swing(1)
				#swing(inventory.inventory[1]["id"])
			elif Input.is_action_pressed("action1"):
				swing(inventory.jRef)
			elif Input.is_action_pressed("action2"):
				swing(inventory.kRef)
		#Collision modifiers
		if Input.is_action_pressed("down"):
			if !world.hasGravity:
				velocity.y = JUMPSPEED
			collision_mask = NO_PLATFORM
			if (checkAllBlocks(30) or checkAllBlocks(188) or checkAllBlocks(204)) and velocity.y == 0:
				coyote = false
				velocity.y = 10
		else:
			collision_mask = DEFAULT_LAYER
		
		if Input.is_action_just_pressed("fly"):
			flying = !flying
		if checkHeadBlocks(117): #Swimming movement
			inWater = true
			update_breathing("water",true)
			if createBubble: #Creates bubbles
				createBubble = false
				effects.create_single_particle(position + Vector2(2,-4),"bubble")
				$BubbleTimer.start()
			if !is_on_floor():
				velocity.y += GRAVITY/ 2.0
			if inControl:
				var speed = MAX_SPEED + movementModifier
				if Input.is_action_pressed("sprint"):
					speed = SPRINT_SPEED + movementModifier
				
				if Input.is_action_pressed("move_left"):
					if velocity.x > -speed:
						velocity.x -= ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				elif Input.is_action_pressed("move_right"):
					if velocity.x < speed:
						velocity.x += ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				else:
					velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				
				if Input.is_action_pressed("jump"):
					if velocity.y > -speed:
						velocity.y -= ACCEL
				elif Input.is_action_pressed("down"):
					if velocity.y < speed:
						velocity.y += ACCEL
			if !swinging:
				if is_on_floor() or (is_on_wall() and player_animations.current_animation == "idle"):
					if abs(velocity.x) > 0:
						player_animations.play("walk")
					else:
						player_animations.play("idle")
				else:
					player_animations.play("swim")
		elif Global.godmode and flying: 
			#Flying movement
			update_breathing("water",false)
			if inControl:
				var speed = MAX_SPEED
				if Input.is_action_pressed("sprint"):
					speed = SPRINT_SPEED
				
				if Input.is_action_pressed("move_left"):
					if velocity.x > -speed:
						velocity.x -= ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				elif Input.is_action_pressed("move_right"):
					if velocity.x < speed:
						velocity.x += ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				else:
					velocity.x = move_toward(velocity.x,0,FRICTION / 2.0)
				
				if Input.is_action_pressed("jump"):
					if velocity.y > -speed:
						velocity.y -= ACCEL
					else:
						velocity.y = move_toward(velocity.y,0,FRICTION / 2.0)
				elif Input.is_action_pressed("down"):
					if velocity.y < speed:
						velocity.y += ACCEL
					else:
						velocity.y = move_toward(velocity.y,0,FRICTION / 2.0)
				else:
					velocity.y = move_toward(velocity.y,0,FRICTION / 2.0)
			
			if !swinging:
				if is_on_floor():
					if velocity.x == 0:
						player_animations.play("idle")
					else:
						player_animations.play("walk")
				else:
					player_animations.play("jump")
		elif world.hasGravity: #Regular movement
			update_breathing("water",false)
			$JetpackParticles.emitting = usingJetpack and jetpackFuel > 0
			if inWater:
				inWater = false
				velocity.y = -JUMPSPEED
				jumping = true
			if !is_on_floor() or knockedBack:
				knockedBack = false
				if jetpackFuel <= 0 or !usingJetpack:
					if !coyote:
						velocity.y += GRAVITY
					elif !timerOn:
						$coyoteTimer.start()
						timerOn = true
			else:
				jetpackFuel = 0
				jumping = false
				coyote = true
			
			if inControl:
				var speed = MAX_SPEED + movementModifier
				if Input.is_action_pressed("sprint"):
					speed = SPRINT_SPEED + movementModifier
				
				if Input.is_action_pressed("move_left"):
					if velocity.x > -speed:
						velocity.x -= ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION)
				elif Input.is_action_pressed("move_right"):
					if velocity.x < speed:
						velocity.x += ACCEL
					else:
						velocity.x = move_toward(velocity.x,0,FRICTION)
				else:
					velocity.x = move_toward(velocity.x,0,FRICTION)
				
				if !swinging:
					if velocity.x == 0:
						player_animations.play("idle")
					else:
						player_animations.play("walk")
				if jetpackLevel <= 0:
					if Input.is_action_just_pressed("jump") and !jumping:
						velocity.y = -JUMPSPEED
						jumping = true
				elif Input.is_action_pressed("jump"):
					usingJetpack = true
					if !jumping or jetpackFuel > 0:
						if !jumping:
							jetpackFuel = 10 * [0,1,2.5,5][jetpackLevel]
						else:
							jetpackFuel -= 1
						velocity.y = -JUMPSPEED
						jumping = true
				else:
					usingJetpack = false
		else: # no gravity Movement
			update_breathing("water",false)
			if inWater:
				inWater = false
				velocity.y = -JUMPSPEED
				jumping = true
			if inControl:
				if Input.is_action_pressed("jump") and velocity.y > -MAX_SPEED:
					velocity.y -= ACCEL
				elif Input.is_action_pressed("down") and velocity.y < MAX_SPEED:
					velocity.y += ACCEL
				if Input.is_action_pressed("move_left") and velocity.x > -MAX_SPEED:
					velocity.x -= ACCEL
				elif Input.is_action_pressed("move_right") and velocity.x < MAX_SPEED:
					velocity.x += ACCEL
				elif is_on_floor():
					velocity.x = move_toward(velocity.x,0,FRICTION)
			if !swinging:
				if is_on_floor():
					if velocity.x == 0:
						player_animations.play("idle")
					else:
						player_animations.play("walk")
				else:
					player_animations.play("jump")
		
		if (get_global_mouse_position().x - position.x < 0 or velocity.x < 0) and !velocity.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(-1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = true
		elif get_global_mouse_position().x - position.x > 0 or velocity.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = false
		if player_animations.current_animation == "walk":
			player_animations.speed_scale = abs(velocity.x) / 40.0
		else:
			player_animations.speed_scale = 1
		move_and_slide()

func swing(loc):
	var item = inventory.inventory[loc]["id"]
	if GlobalData.itemData.has(item) and item > 0 and ["tool","weapon","Hoe","Watering_can"].has(GlobalData.itemData[item]["type"]) and !swinging:
		$Textures/Weapon.texture = GlobalData.get_item_big_texture(item)
		if GlobalData.itemData[item]["type"] == "Watering_can":
			if !swinging:
				player_animations.play("water")
		else:
			player_animations.play("swing")
		swinging = true
		if GlobalData.itemData[item]["type"] == "weapon":
			swing_timer.start(GlobalData.itemData[item]["speed"])
		swingingWith = item
		if GlobalData.itemData[item]["type"] == "weapon":
			$WeaponRange/CollisionShape2D.shape.radius = GlobalData.itemData[swingingWith]["range"]
			await get_tree().physics_frame
			print(toAttack)
			for enemy : CharacterBody2D in toAttack:
				var space_state = get_world_2d().direct_space_state #Ray to make sure no blocks in the way
				var params = PhysicsRayQueryParameters2D.create(position,enemy.position,1,[self])
				var result = space_state.intersect_ray(params)
				if result.is_empty() and sign(enemy.position.x - position.x) == sign(get_global_mouse_position().x - position.x):
					print(enemy)
					match enemy.type:
						"trinanium_charge":
							enemy.update_direction(position.angle_to_point(enemy.position))
						_:
							var dmg = GlobalData.itemData[swingingWith]["dmg"]
							var upgrades : Dictionary = get_item_upgrades(inventory.inventory[loc])
							if upgrades.has("damage"):
								dmg += upgrades["damage"] * 2
							enemy.damage(dmg)
							print("damaged")
							if upgrades.has("poison"):
								enemy.poison(6,upgrades["poison"])
			$WeaponRange/CollisionShape2D.shape.radius = 1

func damage(dmg,enemyLevel : int = 1,knockback : float = 0.0):
	if !dead:
		if !frozen and !poisoned:
			modulate = Color("ff5959")
		var totalDmg = int(round(dmg * max(1-(defPoints/(enemyLevel*25.0)),0)))
		effects.floating_text(position, "-" + str(totalDmg), Color.RED)
		health -= totalDmg
		knockedBack = true
		velocity.x += knockback
		velocity.y -= abs(knockback)
		await get_tree().create_timer(0.5).timeout
		if !frozen and !poisoned:
			modulate = Color.WHITE
		if health < 0:
			die()

func freeze(time : float) -> void:
	modulate = Color("75b2ff")
	frozen = true
	await get_tree().create_timer(time).timeout
	frozen = false
	modulate = Color.WHITE

func poison(amount : float,dmg := 1) -> void:
	modulate = Color("47ff3d")
	poisoned = true
	for i in range(amount):
		await get_tree().create_timer(1).timeout
		damage(dmg)
		if i == amount - 1:
			poisoned = false
			modulate = Color.WHITE

func change_modulate(color : Color) -> void:
	for sprite : Sprite2D in $Textures.get_children():
		sprite.material.set_shader_parameter("modulate",color)

func die():
	dead = true
	effects.death_particles(position)
	collision_layer = 0
	await get_tree().physics_frame
	match Global.gamerules["difficulty"]:
		"normal":
			entities.spawn_blues(Global.blues)
			Global.blues = 0
		"hard":
			entities.spawn_blues(Global.blues)
			Global.blues = 0
			for item : Dictionary in inventory.inventory:
				entities.spawn_item(item,true)
			inventory.inventory.clear()
			inventory.update_inventory()
	hide()
	get_node("../CanvasLayer/Dead").popup()

func _on_coyoteTimer_timeout():
	coyote = false
	timerOn = false

func checkAllBlocks(id : int) -> bool:
	if currentBlocksOn.size() > 0:
		for block in currentBlocksOn:
			if block.id == id:
				return true
	return false

func checkHeadBlocks(id : int) -> bool:
	if currentBlocksOnHead.size() > 0:
		for block in currentBlocksOnHead:
			if block.id == id:
				return true
	return false

func _on_blockTest_body_entered(body):
	if body.id == 145: #Sign area functionality
		if body.data["mode"] == "Area":
			main.display_text(body.data)
	elif !currentBlocksOn.has(body):
		currentBlocksOn.append(body)

func _on_blockTest_body_exited(body):
	if currentBlocksOn.has(body):
		currentBlocksOn.erase(body)

func get_item_upgrades(itemData : Dictionary) -> Dictionary:
	var upgrades : Dictionary
	if itemData.has("data"):
		if itemData["data"].has("upgrades"):
			for slot : String in itemData["data"]["upgrades"]:
				if upgrades.has(itemData["data"]["upgrades"][slot]):
					upgrades[itemData["data"]["upgrades"][slot]] += 1
				else:
					upgrades[itemData["data"]["upgrades"][slot]] = 1
	else:
		itemData["data"] = {}
	return upgrades

func update_character() -> void:
	gender = Global.playerBase["sex"]
	$Textures/body.texture = load("res://textures/player/base/" + gender + ".png")
	eyeTexture = GlobalData.get_eye_texture()
	$Textures/eyes.texture = eyeTexture

func get_armor_buff() -> String:
	for buff in GlobalData.armor_buffs:
		var hasBuff = true
		for requiredArmor in GlobalData.armor_buffs[buff]["requires"]:
			if !currentWearing.values().has(requiredArmor):
				hasBuff = false
		if hasBuff:
			return buff
	return "none"

func _on_Armor_updated_armor(armorData : Dictionary):
	if world != null:
		update_character()
		var type : Dictionary = {"Shirt":"shirt","Chestplate":"shirt","Pants":"pants","Leggings":"pants","Boots":"boots","Shoes":"boots","Hat":"headwear","Helmet":"headwear"}
		var wearing : Dictionary = {"pants":0,"shirt":0,"boots":0,"headwear":0}
		defPoints = 0
		movementModifier = 0
		maxOxygen = 50
		for armorType in armorData:
			if !armorData[armorType].is_empty():
				var id = armorData[armorType]["id"]
				wearing[type[armorType]] = id
				if ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
					var def = GlobalData.itemData[id]["armor_data"]["def"]
					movementModifier += GlobalData.itemData[id]["armor_data"]["speed"]
					if get_item_upgrades(armorData[armorType]).has("protection"):
						def += get_item_upgrades(armorData[armorType])["protection"]
					if def > 0:
						defPoints += def
						armor.get_node(armorType + "Points").show()
						armor.get_node(armorType + "Points").text = "+" + str(def) + " Def"
					else:
						armor.get_node(armorType + "Points").hide()
				if !["Shirt","Chestplate"].has(armorType):
					if ["Leggings","Pants"].has(armorType) and get_item_upgrades(armorData[armorType]).has("movement_speed"):
						movementModifier += get_item_upgrades(armorData[armorType])["movement_speed"] * 2
					elif ["Hat","Helmet"].has(armorType) and get_item_upgrades(armorData[armorType]).has("oxygen"):
						maxOxygen += get_item_upgrades(armorData[armorType])["oxygen"] * 50
				else:
					if armorType == "Chestplate":
						if get_item_upgrades(armorData[armorType]).has("jetpack"):
							jetpackLevel = get_item_upgrades(armorData[armorType])["jetpack"]
						else:
							jetpackLevel = 0
			elif ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
				if armorType == "Chestplate":
					jetpackLevel = 0
				$"../CanvasLayer/Inventory/Armor".get_node(armorType + "Points").hide()
		movementModifier *= 4
		for layer : Sprite2D in $Textures/Clothes.get_children():
			layer.hide()
		for clothesType : String in wearing:
			var wearingId : int = wearing[clothesType]
			if wearingId == 0:
				match clothesType:
					"headwear":
						$Textures/Clothes/head.show()
						$Textures/Clothes/head.modulate = Global.playerBase["hair_color"]
						$Textures/Clothes/head.texture = load("res://textures/player/hair/" + Global.playerBase["hair_style"] + ".png")
					"shirt":
						if gender == "female":
							$Textures/Clothes/torso.show()
							$Textures/Clothes/torso.texture = load("res://textures/player/wearables/torso/undergarments_female.png")
					"pants":
						$Textures/Clothes/left_leg.show()
						$Textures/Clothes/right_leg.show()
						$Textures/Clothes/left_leg.texture = load("res://textures/player/wearables/left_leg/undergarments.png")
						$Textures/Clothes/right_leg.texture = load("res://textures/player/wearables/right_leg/undergarments.png")
			else:
				if clothesType == "headwear":
					$Textures/Clothes/head.modulate = Color.WHITE
				for layer : String in clothesSpritesheets[wearingId]["contains"]:
					clothes.get_node(layer).show()
					clothes.get_node(layer).texture = load("res://textures/player/wearables/" + layer + "/"+ clothesSpritesheets[wearingId]["name"] + (("_" + gender) if layer == "torso" else "") +".png")
		currentWearing = wearing
		var currentBuff = get_armor_buff()
		match currentBuff:
			"cold_resistance":
				GlobalGui.complete_achievement("Winter ready")
			"heat_resistance":
				GlobalGui.complete_achievement("Scorched ready")
		update_breathing("atmo",StarSystem.find_planet_id(Global.currentPlanet) != null and StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere)
		if is_instance_valid(StarSystem.find_planet_id(Global.currentPlanet)):
			match StarSystem.find_planet_id(Global.currentPlanet).type["type"]:
				"scorched":
					currentTemp = 1
					$"../CanvasLayer/Warnings/Fire".show()
					$"../CanvasLayer/Warnings/Frozen".hide()
					$"../CanvasLayer/Warnings/Fire".modulate = Color.WHITE if currentBuff != "heat_resistance" else Color(1,1,1,0.5)
				"frigid":
					currentTemp = -1
					$"../CanvasLayer/Warnings/Frozen".show()
					$"../CanvasLayer/Warnings/Fire".hide()
					$"../CanvasLayer/Warnings/Frozen".modulate = Color.WHITE if currentBuff != "cold_resistance" else Color(1,1,1,0.5)
				_:
					currentTemp = 0
					$"../CanvasLayer/Warnings/Fire".hide()
					$"../CanvasLayer/Warnings/Frozen".hide()
		else:
			currentTemp = 0
		armorBuff = currentBuff

func step() -> void:
	if currentBlocksOn.size() > 0:
		GlobalAudio.play_block_audio_2d(currentBlocksOn[0].id,"step",position)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"swing","water":
			if GlobalData.itemData[swingingWith]["type"] != "weapon":
				swinging = false

func update_breathing(setTo : String, value : bool) -> void:
	if setTo == "atmo":
		canBreath = value
	else:
		underWater = value
	$"../CanvasLayer/Warnings/NoOxygen".visible = !canBreath or underWater
	$"../CanvasLayer/Warnings/NoOxygen".modulate = Color.WHITE if get_armor_buff() != "air_tight" else Color(1,1,1,0.5)

func _on_tick_timeout() -> void:
	if !canBreath or underWater:
		if armorBuff == "air_tight" and suitOxygen > 0:
			suitOxygen -= 1
			if oxygen < maxOxygen:
				oxygen += 1
				suitOxygen -= 1
				if oxygen > maxOxygen:
					oxygen = maxOxygen
		elif oxygen > 0:
			oxygen -= 1
		else:
			damage(1)
	else:
		if oxygen < maxOxygen:
			oxygen += 1
			if oxygen > maxOxygen:
				oxygen = maxOxygen
		if suitOxygen < suitOxygenMax:
			suitOxygen += 5
			if suitOxygen > suitOxygenMax:
				suitOxygen = suitOxygenMax
	if (currentTemp > 0 and armorBuff != "heat_resistance") or (currentTemp < 0 and armorBuff != "cold_resistance"):
		damage(1)

func _on_swing_timer_timeout() -> void:
	swinging = false

func _on_weapon_range_area_entered(area: Area2D) -> void:
	if !toAttack.has(area.get_parent()):
		toAttack.append(area.get_parent())

func _on_weapon_range_area_exited(area: Area2D) -> void:
	if toAttack.has(area.get_parent()):
		toAttack.erase(area.get_parent())

func _on_head_test_body_entered(body: Node2D) -> void:
	if !currentBlocksOnHead.has(body):
		currentBlocksOnHead.append(body)

func _on_head_test_body_exited(body: Node2D) -> void:
	if currentBlocksOnHead.has(body):
		currentBlocksOnHead.erase(body)

func _on_bubble_timer_timeout() -> void:
	createBubble = true
