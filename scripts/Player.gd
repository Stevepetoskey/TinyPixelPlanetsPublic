extends KinematicBody2D

const GRAVITY = 4
const ACCEL = 8
const MAX_SPEED = 30
const FRICTION = 4
const JUMPSPEED = 75

#Collision
const DEFAULT_LAYER = 5
const NO_PLATFORM = 1

onready var cursor = get_node("../Cursor")
onready var armor = get_node("../CanvasLayer/Inventory/Armor")

var motion = Vector2(0,0)

var coyote = true
var timerOn = false
var jumping = false
var currentBlocksOn = []

var maxHealth = 50
var health = 50

var maxOxygen = 50
var oxygen = 50

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

func _physics_process(_delta):
	#Collision modifiers
	if Input.is_action_pressed("down"):
		collision_mask = NO_PLATFORM
		if checkAllBlocks(30) and motion.y == 0:
			coyote = false
			motion.y = 10
	else:
		collision_mask = DEFAULT_LAYER
	
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
	
	if Input.is_action_pressed("move_left"):
		if motion.x > -MAX_SPEED:
			motion.x -= ACCEL
	elif Input.is_action_pressed("move_right"):
		if motion.x < MAX_SPEED:
			motion.x += ACCEL
	else:
		motion.x = move_toward(motion.x,0,FRICTION)
	
	if motion.x == 0:
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("walk")
	
	if Input.is_action_just_pressed("jump") and motion.y <= GRAVITY and !jumping:
		motion.y = -JUMPSPEED
		jumping = true
	
	if motion.x > 0:
		$AnimatedSprite.flip_h = false
	elif motion.x < 0:
		$AnimatedSprite.flip_h = true
	
	motion = move_and_slide(motion,Vector2(0,-1))

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
	var set = {"Shirt":"shirt","Chestplate":"shirt","Pants":"pants","Leggings":"pants","Boots":"boots","Shoes":"boots","Hat":"headwear","Helmet":"headwear"}
	var display = {"pants":null,"shirt":null,"boots":null,"headwear":null}
	for armorType in armorData:
		if !armorData[armorType].empty():
			var id = armorData[armorType]["id"]
			if !["Shirt","Chestplate"].has(armorType):
				display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + files[id]["file"])
			else:
				display[set[armorType]] = load("res://textures/player/" + files[id]["folder"]+ "/" + gender + "/" + files[id]["file"])
	for sheet in display:
		if display[sheet] == null:
			get_node(sheet).hide()
		else:
			get_node(sheet).show()
			get_node(sheet).texture = display[sheet]
