extends CharacterBody2D

const GRAVITY = 4
const ACCEL = 8
const MAX_SPEED = 30
const SPRINT_SPEED = 60
const FRICTION = 4
const JUMPSPEED = 75

#Collision
const DEFAULT_LAYER = 5
const NO_PLATFORM = 1

@onready var cursor = get_node("../Cursor")
@onready var armor = get_node("../CanvasLayer/Inventory/Armor")
@onready var effects = get_node("../Effects")
@onready var inventory = get_node("../CanvasLayer/Inventory")
@onready var world = get_node("../World")
@onready var entities = get_node("../Entities")
@onready var main: Node2D = $".."
@onready var swing_timer: Timer = $SwingTimer

var type = "player"
var coyote = true
var timerOn = false
var jumping = false
var swinging : bool = false
var swingingWith : int = 0
var currentBlocksOn = []
var canBreath = true
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

var dead = false
var flipped = false

var toAttack = []

var maxHealth = 50
var health = 50

var maxOxygen = 50
var oxygen = 50
var suitOxygen = 500
var suitOxygenMax = 500

var gender = "Guy"
var files = {32:{"folder":"Tops","file":"Shirt.png"},
	33:{"folder":"Bottoms","file":"Jeans.png"},
	34:{"folder":"Shoes","file":"Black.png"},
	35:{"folder":"Headwear","file":"Copper.png"},
	36:{"folder":"Tops","file":"Copper.png"},
	37:{"folder":"Bottoms","file":"Copper.png"},
	38:{"folder":"Shoes","file":"Copper.png"},
	39:{"folder":"Headwear","file":"Silver.png"},
	40:{"folder":"Tops","file":"Silver.png"},
	41:{"folder":"Bottoms","file":"Silver.png"},
	42:{"folder":"Shoes","file":"Silver.png"},
	43:{"folder":"Tops","file":"Tuxedo.png"},
	44:{"folder":"Bottoms","file":"Slacks.png"},
	45:{"folder":"Headwear","file":"Top_hat.png"},
	46:{"folder":"Headwear","file":"Space.png"},
	47:{"folder":"Tops","file":"Space.png"},
	48:{"folder":"Bottoms","file":"Space.png"},
	49:{"folder":"Shoes","file":"Space.png"},
	50:{"folder":"Tops","file":"Red_Dress.png"},
	51:{"folder":"Bottoms","file":"Red_Dress.png"},
	207:{"folder":"Headwear","file":"Coat.png"},
	208:{"folder":"Tops","file":"Coat.png"},
	209:{"folder":"Bottoms","file":"Coat.png"},
	210:{"folder":"Shoes","file":"Coat.png"},
	211:{"folder":"Headwear","file":"Fire.png"},
	212:{"folder":"Tops","file":"Fire.png"},
	213:{"folder":"Bottoms","file":"Fire.png"},
	214:{"folder":"Shoes","file":"Fire.png"},
	}

func _ready():
	$Textures/body.texture = load("res://textures/player/Body/" + gender + ".png")
	if health < 0:
		dead = true
		effects.death_particles(position)
		hide()
		get_node("../CanvasLayer/Dead").popup()
	_on_Armor_updated_armor(armor.armor)

func _physics_process(_delta):
	if !dead and !Global.pause and !frozen:
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
			if checkAllBlocks(30) and velocity.y == 0:
				coyote = false
				velocity.y = 10
		else:
			collision_mask = DEFAULT_LAYER
		
		if Input.is_action_just_pressed("fly"):
			flying = !flying
		if checkAllBlocks(117): #Swimming movement
			inWater = true
			if !is_on_floor():
				velocity.y += GRAVITY/ 2.0
			
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
				if is_on_floor() or (is_on_wall() and $Textures/AnimationPlayer.current_animation == "idle"):
					if abs(velocity.x) > 0:
						$Textures/AnimationPlayer.play("walk")
					else:
						$Textures/AnimationPlayer.play("idle")
				else:
					$Textures/AnimationPlayer.play("swim")
		elif Global.godmode and flying: 
			#Flying movement
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
						$Textures/AnimationPlayer.play("idle")
					else:
						$Textures/AnimationPlayer.play("walk")
				else:
					$Textures/AnimationPlayer.play("jump")
		elif world.hasGravity: #Regular movement
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
					$Textures/AnimationPlayer.play("idle")
				else:
					$Textures/AnimationPlayer.play("walk")
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
			if inWater:
				inWater = false
				velocity.y = -JUMPSPEED
				jumping = true
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
						$Textures/AnimationPlayer.play("idle")
					else:
						$Textures/AnimationPlayer.play("walk")
				else:
					$Textures/AnimationPlayer.play("jump")
		
		if (get_global_mouse_position().x - position.x < 0 or velocity.x < 0) and !velocity.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(-1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = true
		elif get_global_mouse_position().x - position.x > 0 or velocity.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = false
		#set_up_direction(Vector2(0,-1))
		#set_floor_stop_on_slope_enabled(true)
		move_and_slide()

func swing(loc):
	var item = inventory.inventory[loc]["id"]
	if world.itemData.has(item) and item > 0 and ["tool","weapon","Hoe","Watering_can"].has(world.itemData[item]["type"]) and !swinging:
		$Textures/Weapon.texture = world.itemData[item]["big_texture"]
		if world.itemData[item]["type"] == "Watering_can":
			if !swinging:
				$Textures/AnimationPlayer.play("water")
		else:
			$Textures/AnimationPlayer.play("swing")
		swinging = true
		if world.itemData[item]["type"] == "weapon":
			swing_timer.start(world.itemData[item]["speed"])
		swingingWith = item
		if world.itemData[item]["type"] == "weapon":
			$WeaponRange/CollisionShape2D.shape.radius = world.itemData[swingingWith]["range"]
			await get_tree().physics_frame
			for enemy : CharacterBody2D in toAttack:
				var space_state = get_world_2d().direct_space_state #Ray to make sure no blocks in the way
				var params = PhysicsRayQueryParameters2D.create(position,enemy.position,1,[self])
				var result = space_state.intersect_ray(params)
				if result.is_empty() and sign(enemy.position.x - position.x) == sign(get_global_mouse_position().x - position.x):
					match enemy.type:
						"trinanium_charge":
							print("sending em back")
							print("old dir: ",enemy.direction)
							enemy.update_direction(position.angle_to_point(enemy.position))
							print("new dir: ",enemy.direction)
						_:
							var dmg = world.itemData[swingingWith]["dmg"]
							var upgrades : Dictionary = get_item_upgrades(inventory.inventory[loc])
							if upgrades.has("damage"):
								dmg += upgrades["damage"] * 2
							enemy.damage(dmg)
							if upgrades.has("poison"):
								enemy.poison(6,upgrades["poison"])
			$WeaponRange/CollisionShape2D.shape.radius = 1

func damage(dmg,enemyLevel : int = 1,knockback : float = 0.0):
	if !dead and !Global.pause:
		if !frozen and !poisoned:
			modulate = Color("ff5959")
		var totalDmg = int(round(dmg * max(1-(defPoints/(enemyLevel*25.0)),0)))
		effects.floating_text(position, "-" + str(totalDmg), Color.RED)
		health -= totalDmg
		print(knockback)
		knockedBack = true
		velocity.x += knockback
		velocity.y -= abs(knockback)
		await get_tree().create_timer(0.5).timeout
		if health < 0:
			die()
		if !frozen and !poisoned:
			modulate = Global.lightColor

func freeze(time : float) -> void:
	modulate = Color("75b2ff")
	frozen = true
	await get_tree().create_timer(time).timeout
	frozen = false
	modulate = Global.lightColor

func poison(amount : float,dmg := 1) -> void:
	modulate = Color("47ff3d")
	poisoned = true
	for i in range(amount):
		await get_tree().create_timer(1).timeout
		damage(dmg)
		if i == amount - 1:
			poisoned = false
			modulate = Global.lightColor

func die():
	dead = true
	effects.death_particles(position)
	hide()
	get_node("../CanvasLayer/Dead").popup()

func _on_coyoteTimer_timeout():
	coyote = false
	timerOn = false

func checkAllBlocks(id : int) -> bool:
	if currentBlocksOn.size() == 0:
		return false
	for block in currentBlocksOn:
		if block.id != id:
			return false
	return true

func _on_blockTest_body_entered(body):
	if body.id == 145:
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

func _on_Armor_updated_armor(armorData):
	if world != null:
		$Textures/body.texture = load("res://textures/player/Body/" + gender + ".png")
		var set = {"Shirt":"shirt","Chestplate":"shirt","Pants":"pants","Leggings":"pants","Boots":"boots","Shoes":"boots","Hat":"headwear","Helmet":"headwear"}
		var display = {"pants":null,"shirt":null,"boots":null,"headwear":null}
		var wearing = {"pants":0,"shirt":0,"boots":0,"headwear":0}
		defPoints = 0
		movementModifier = 0
		maxOxygen = 50
		for armorType in armorData:
			if !armorData[armorType].is_empty():
				var id = armorData[armorType]["id"]
				wearing[set[armorType]] = id
				if ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
					var def = world.itemData[id]["armor_data"]["def"]
					movementModifier += world.itemData[id]["armor_data"]["speed"]
					if get_item_upgrades(armorData[armorType]).has("protection"):
						def += get_item_upgrades(armorData[armorType])["protection"]
					if def > 0:
						defPoints += def
						armor.get_node(armorType + "Points").show()
						armor.get_node(armorType + "Points").text = "+" + str(def) + " Def"
					else:
						armor.get_node(armorType + "Points").hide()
				if !["Shirt","Chestplate"].has(armorType):
					display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + files[id]["file"])
					if ["Leggings","Pants"].has(armorType) and get_item_upgrades(armorData[armorType]).has("movement_speed"):
						movementModifier += get_item_upgrades(armorData[armorType])["movement_speed"] * 2
					elif ["Hat","Helmet"].has(armorType) and get_item_upgrades(armorData[armorType]).has("oxygen"):
						maxOxygen += get_item_upgrades(armorData[armorType])["oxygen"] * 50
				else:
					if get_item_upgrades(armorData[armorType]).has("jetpack"):
						jetpackLevel = get_item_upgrades(armorData[armorType])["jetpack"]
					else:
						jetpackLevel = 0
					display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + gender + "/" + files[id]["file"])
			elif ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
				jetpackLevel = 0
				$"../CanvasLayer/Inventory/Armor".get_node(armorType + "Points").hide()
		movementModifier *= 4
		for sheet in display:
			if display[sheet] == null:
				match sheet:
					"headwear":
						$Textures/headwear.show()
						$Textures/headwear.modulate = Global.playerBase["hair_color"]
						$Textures/headwear.texture = load("res://textures/player/Hair/" + Global.playerBase["hair_style"] + ".png")
					"shirt":
						$Textures/shirt.show()
						$Textures/shirt.texture = load("res://textures/player/Body/underTop-" + gender + ".png")
					"pants":
						$Textures/pants.show()
						$Textures/pants.texture = load("res://textures/player/Body/under-" + gender + ".png")
					_:
						$Textures.get_node(sheet).hide()
			else:
				if sheet == "headwear":
					$Textures/headwear.modulate = Color.WHITE
				$Textures.get_node(sheet).show()
				$Textures.get_node(sheet).texture = display[sheet]
		var currentBuff = ""
		for buff in GlobalData.armor_buffs:
			var hasBuff = true
			for requiredArmor in GlobalData.armor_buffs[buff]["requires"]:
				if !wearing.values().has(requiredArmor):
					hasBuff = false
			if hasBuff:
				currentBuff = buff
				break
		if StarSystem.find_planet_id(Global.currentPlanet) != null and StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere:
			canBreath = true
		else:
			canBreath = false
		$"../CanvasLayer/Warnings/NoOxygen".visible = !canBreath
		$"../CanvasLayer/Warnings/NoOxygen".modulate = Color.WHITE if currentBuff != "air_tight" else Color(1,1,1,0.5)
		if is_instance_valid(StarSystem.find_planet_id(Global.currentPlanet)):
			match StarSystem.find_planet_id(Global.currentPlanet).type["type"]:
				"scorched":
					currentTemp = 1
					$"../CanvasLayer/Warnings/Fire".show()
					$"../CanvasLayer/Warnings/Frozen".hide()
					$"../CanvasLayer/Warnings/Fire".modulate = Color.WHITE if currentBuff != "heat_resistance" else Color(1,1,1,0.5)
				"fridged":
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

func _on_AnimationPlayer_animation_finished(anim_name):
	if ["swing","water"].has(anim_name) and world.itemData[swingingWith]["type"] != "weapon":
		swinging = false

func _on_tick_timeout() -> void:
	if !Global.pause:
		if !canBreath:
			if armorBuff == "air_tight" and suitOxygen > 0:
				suitOxygen -= 1
				if oxygen < maxOxygen:
					oxygen += 1
					suitOxygen -= 1
					if oxygen > maxOxygen:
						oxygen = maxOxygen
			elif oxygen > 0:
				oxygen -= 1
			elif health >0:
				health -= 1
				if health <= 0:
					die()
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
			health -= 1

func _on_swing_timer_timeout() -> void:
	swinging = false

func _on_weapon_range_area_entered(area: Area2D) -> void:
	if !toAttack.has(area.get_parent()):
		toAttack.append(area.get_parent())

func _on_weapon_range_area_exited(area: Area2D) -> void:
	if toAttack.has(area.get_parent()):
		toAttack.erase(area.get_parent())
