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

var motion = Vector2(0,0)

var coyote = true
var timerOn = false
var jumping = false
var swinging = false
var swingingWith = 0
var currentBlocksOn = []
var canBreath = true
var inSuit = false
var flying = false
var defPoints = 0
var inWater = false

var dead = false
var flipped = false

var enemies = []

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
	if !dead and !Global.pause:
		#Swinging process
		if inventory.inventory.size() > 0:
			if Input.is_action_pressed("build"):
				swing(inventory.inventory[0]["id"])
			elif Input.is_action_pressed("build2") and inventory.inventory.size() > 1:
				swing(inventory.inventory[1]["id"])
			elif Input.is_action_pressed("action1"):
				swing(inventory.jId)
			elif Input.is_action_pressed("action2"):
				swing(inventory.kId)
			else:
				swinging = false
				if $Textures/AnimationPlayer.current_animation == "water":
					$Textures/AnimationPlayer.play("idle")
		#Collision modifiers
		if Input.is_action_pressed("down"):
			if !world.hasGravity:
				motion.y = JUMPSPEED
			collision_mask = NO_PLATFORM
			if checkAllBlocks(30) and motion.y == 0:
				coyote = false
				motion.y = 10
		else:
			collision_mask = DEFAULT_LAYER
		
		if Input.is_action_just_pressed("fly"):
			flying = !flying
		if checkAllBlocks(117): #Swimming movement
			inWater = true
			if !is_on_floor():
				motion.y += GRAVITY/ 2.0
			
			var speed = MAX_SPEED
			if Input.is_action_pressed("sprint"):
				speed = SPRINT_SPEED
			
			if Input.is_action_pressed("move_left"):
				if motion.x > -speed:
					motion.x -= ACCEL
				else:
					motion.x = move_toward(motion.x,0,FRICTION / 2.0)
			elif Input.is_action_pressed("move_right"):
				if motion.x < speed:
					motion.x += ACCEL
				else:
					motion.x = move_toward(motion.x,0,FRICTION / 2.0)
			else:
				motion.x = move_toward(motion.x,0,FRICTION / 2.0)
			
			if Input.is_action_pressed("jump"):
				if motion.y > -speed:
					motion.y -= ACCEL
			elif Input.is_action_pressed("down"):
				if motion.y < speed:
					motion.y += ACCEL
			if !swinging:
				if is_on_floor() or (is_on_wall() and $Textures/AnimationPlayer.current_animation == "idle"):
					if abs(motion.x) > 0:
						$Textures/AnimationPlayer.play("walk")
					else:
						$Textures/AnimationPlayer.play("idle")
				else:
					$Textures/AnimationPlayer.play("swim")
		elif world.hasGravity and (!Global.godmode or !flying): #Regular movement
			if inWater:
				inWater = false
				motion.y = -JUMPSPEED
				jumping = true
			if !is_on_floor():
				if !coyote:
					motion.y += GRAVITY
				elif !timerOn:
					$coyoteTimer.start()
					timerOn = true
			else:
				motion.y = 0
				jumping = false
				coyote = true
			
			var speed = MAX_SPEED
			if Input.is_action_pressed("sprint"):
				speed = SPRINT_SPEED
			
			if Input.is_action_pressed("move_left"):
				if motion.x > -speed:
					motion.x -= ACCEL
				else:
					motion.x = move_toward(motion.x,0,FRICTION)
			elif Input.is_action_pressed("move_right"):
				if motion.x < speed:
					motion.x += ACCEL
				else:
					motion.x = move_toward(motion.x,0,FRICTION)
			else:
				motion.x = move_toward(motion.x,0,FRICTION)
			
			if !swinging:
				if motion.x == 0:
					$Textures/AnimationPlayer.play("idle")
				else:
					$Textures/AnimationPlayer.play("walk")
			
			if Input.is_action_just_pressed("jump") and !jumping:
				motion.y = -JUMPSPEED
				jumping = true
		else: # Flying/ no gravity Movement
			if inWater:
				inWater = false
				motion.y = -JUMPSPEED
				jumping = true
			if Input.is_action_pressed("jump") and motion.y > -MAX_SPEED:
				motion.y -= ACCEL
			elif Input.is_action_pressed("down") and motion.y < MAX_SPEED:
				motion.y += ACCEL
			if Input.is_action_pressed("move_left") and motion.x > -MAX_SPEED:
				motion.x -= ACCEL
			elif Input.is_action_pressed("move_right") and motion.x < MAX_SPEED:
				motion.x += ACCEL
			elif is_on_floor():
				motion.x = move_toward(motion.x,0,FRICTION)
			if !swinging:
				if is_on_floor():
					if motion.x == 0:
						$Textures/AnimationPlayer.play("idle")
					else:
						$Textures/AnimationPlayer.play("walk")
				else:
					$Textures/AnimationPlayer.play("jump")
		
		if (get_global_mouse_position().x - position.x < 0 or motion.x < 0) and !motion.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(-1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = true
		elif get_global_mouse_position().x - position.x > 0 or motion.x > 0:
			$Textures.set_global_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(position.x,position.y)))
			flipped = false
		
		set_velocity(motion)
		set_up_direction(Vector2(0,-1))
		set_floor_stop_on_slope_enabled(true)
		move_and_slide()
		motion = velocity

func swing(item):
	if world.itemData.has(item) and item > 0 and ["Tool","weapon","Hoe","Watering_can"].has(world.itemData[item]["type"]) and !swinging:
		$Textures/Weapon.texture = world.itemData[item]["big_texture"]
		if world.itemData[item]["type"] == "Watering_can":
			if !swinging:
				$Textures/AnimationPlayer.play("water")
		else:
			$Textures/AnimationPlayer.play("swing")
		swinging = true
		swingingWith = item
		if world.itemData[item]["type"] == "weapon":
			for enemy in entities.get_node("Hold").get_children():
				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_ray(position, enemy.position, [self], 1)
				if result.is_empty() and position.distance_to(enemy.position) < world.itemData[swingingWith]["range"] and sign(enemy.position.x - position.x) == sign(get_global_mouse_position().x - position.x):
					enemy.damage(world.itemData[swingingWith]["dmg"])

func damage(dmg,enemyLevel = 1):
	if !dead and !Global.pause:
		modulate = Color("ff5959")
		var totalDmg = int(round(dmg * max(1-(defPoints/(enemyLevel*25.0)),0)))
		effects.floating_text(position, "-" + str(totalDmg), Color.RED)
		health -= totalDmg
		await get_tree().create_timer(0.5).timeout
		if health < 0:
			die()
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
	if !currentBlocksOn.has(body):
		currentBlocksOn.append(body)

func _on_blockTest_body_exited(body):
	if currentBlocksOn.has(body):
		currentBlocksOn.erase(body)

func _on_Armor_updated_armor(armorData):
	if world != null:
		$Textures/body.texture = load("res://textures/player/Body/" + gender + ".png")
		var set = {"Shirt":"shirt","Chestplate":"shirt","Pants":"pants","Leggings":"pants","Boots":"boots","Shoes":"boots","Hat":"headwear","Helmet":"headwear"}
		var display = {"pants":null,"shirt":null,"boots":null,"headwear":null}
		var wearing = {"pants":0,"shirt":0,"boots":0,"headwear":0}
		defPoints = 0
		for armorType in armorData:
			if !armorData[armorType].is_empty():
				var id = armorData[armorType]["id"]
				wearing[set[armorType]] = id
				if ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
					var def = world.itemData[id]["armor_data"]["def"]
					if def > 0:
						defPoints += def
						armor.get_node(armorType + "Points").show()
						armor.get_node(armorType + "Points").text = "+" + str(def) + " Def"
					else:
						armor.get_node(armorType + "Points").hide()
				if !["Shirt","Chestplate"].has(armorType):
					display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + files[id]["file"])
				else:
					display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + gender + "/" + files[id]["file"])
			elif ["Chestplate","Leggings","Boots","Helmet"].has(armorType):
				$"../CanvasLayer/Inventory/Armor".get_node(armorType + "Points").hide()
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
		var fullSuit = true
		if wearing.values() != [48,47,49,46]:
			fullSuit = false
		if StarSystem.find_planet_id(Global.currentPlanet) != null and StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere:
			canBreath = true
		else:
			canBreath = false
		inSuit = fullSuit

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "swing":
		swinging = false

func _on_Oxygen_timeout():
	if !canBreath:
		if inSuit and suitOxygen > 0:
			suitOxygen -= 1
			if oxygen < maxOxygen:
				oxygen += 1
				suitOxygen -= 1
				if oxygen > maxOxygen:
					oxygen = maxOxygen
		elif oxygen > 0:
			oxygen -= 1
		elif health > 0:
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
