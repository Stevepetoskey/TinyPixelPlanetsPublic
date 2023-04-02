extends StaticBody2D

const SHADE_TEX = preload("res://textures/blocks2X/shade.png")

export var id = 1
export var layer = 1

onready var world = get_node("../..")

var data = {}
var pos : Vector2

var falling = false
var fallPos : Vector2

func _ready():
	var mainCol = $CollisionShape2D
	if id != 30:
		$platform.queue_free()
	else:
		$CollisionShape2D.queue_free()
		collision_layer = 4
		mainCol = $platform
	
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
	z_index = layer
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks",self,"on_update")
	world.connect("world_loaded",self,"world_loaded")
	match id:
		1,24:
			$check.start(rand_range(10,60))
		9:
			var isSnow = ""
			if ["snow","snow_terra"].has(StarSystem.find_planet_id(Global.currentPlanet).type["type"]):
				isSnow = "_snow"
			$CollisionShape2D.disabled = true
			$Sprite.texture = load("res://textures/blocks2X/big_tree"+ isSnow+".png")
			position.x += 0.5
			position.y -= 23
#			if randi() % 2 == 1:
#				position.y -= 1
#				$Sprite.texture = load("res://textures/blocks/tree2"+ isSnow+".png")
		6,7:
			$CollisionShape2D.disabled = true
#		20:
#			$Sprite.texture = load("res://textures/blocks/glass_full.png")
#		18:
#			yield(get_tree().create_timer())
#			if pos.y < world.worldSize.y -1 and world.get_block_id(pos + Vector2(0,1),layer) == 0:
#				$Tick.start()

func world_loaded():
	on_update()

func on_update():
	if layer < 1:
		if world.transparentBlocks.has(world.get_block_id(pos,1)) and ([0,10].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
			show()
		else:
			hide()
		if world.worldLoaded and visible:
			for x in range(-1,2):
				for y in range(-1,2):
					if abs(x) != abs(y):
						if ![0,6,7,9,30].has(world.get_block_id(pos + Vector2(x,y),1)) and !$shade.has_node(str(x) + str(y)):
							var shade = Sprite.new()
							shade.texture = SHADE_TEX
							shade.name = str(x) + str(y)
							shade.rotation = deg2rad({Vector2(0,1):0,Vector2(-1,0):90,Vector2(0,-1):180,Vector2(1,0):270}[Vector2(x,y)])
							$shade.add_child(shade)
						elif world.get_block_id(pos + Vector2(x,y),1) == 0 and $shade.has_node(str(x) + str(y)):
							$shade.get_node(str(x) + str(y)).queue_free()
	
	if world.worldLoaded and visible:
		match id:
			10:
				if world.get_block_id(pos - Vector2(0,1),layer) == 10 or world.get_block_id(pos + Vector2(0,1),layer) == 10:
					$Sprite.texture = load("res://textures/blocks2X/log_v.png")
				elif world.get_block_id(pos - Vector2(1,0),layer) == 10 or world.get_block_id(pos + Vector2(1,0),layer) == 10:
					$Sprite.texture = load("res://textures/blocks2X/log_h.png")
				else:
					$Sprite.texture = load("res://textures/blocks2X/log_front.png")
			18,14:
				if !falling and pos.y < world.worldSize.y -1:
					if world.get_block_id(pos + Vector2(0,1),layer) == 0:
						falling = true
						fallPos = pos + Vector2(0,1)
						$Tick.start()
					elif world.get_block_id(pos + Vector2(0,1),layer) == id:
						if pos.x < world.worldSize.x - 1 and world.get_block_id(pos + Vector2(1,1),layer) == 0:
							falling = true
							fallPos = pos + Vector2(1,1)
							$Tick.start()
						elif pos.x > 0 and world.get_block_id(pos + Vector2(-1,1),layer) == 0:
							falling = true
							fallPos = pos + Vector2(-1,1)
							$Tick.start()
			30:
				var textures = {[false,false]:"res://textures/blocks2X/platform_full.png",[false,true]:"res://textures/blocks2X/platform_left.png",[true,false]:"res://textures/blocks2X/platform_right.png",[true,true]:"res://textures/blocks2X/platform_mid.png"}
				var around = [world.get_block_id(pos - Vector2(1,0),layer) == 30,world.get_block_id(pos + Vector2(1,0),layer) == 30]
				$Sprite.texture = load(textures[around])
#			20:
#				var spaces = [world.get_block_id(pos + Vector2(1,0),layer) == 20,world.get_block_id(pos - Vector2(0,1),layer) == 20,world.get_block_id(pos - Vector2(1,0),layer) == 20,world.get_block_id(pos + Vector2(0,1),layer) == 20]
#				if !spaces.has(true):
#					$Sprite.texture = load("res://textures/blocks/glass_full.png")
#				else:
#					$Sprite.texture = load("res://textures/blocks/glass_middle.png")
#				for space in spaces:
#					if space and 

func _on_Tick_timeout():
	match id:
		18,14:
			if world.get_block(pos+ Vector2(2,0),layer) != null and world.get_block(pos+ Vector2(2,0),layer).falling:
				yield(get_tree(),"idle_frame")
			if world.get_block_id(fallPos,layer) == 0:
				world.set_block(fallPos,layer,id)
				world.set_block(pos,layer,0,true)
			falling = false

func _on_VisibilityNotifier2D_screen_entered():
	show()
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	hide()

func _on_check_timeout():
	match id:
		1:
			var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet)
			if ["desert","stone","snow"].has(currentPlanet.type["type"]) or !currentPlanet.hasAtmosphere:
				world.set_block(pos,layer,2)
			if ["snow_terra"].has(currentPlanet.type["type"]):
				world.set_block(pos,layer,24)
		24:
			var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet)
			if ["terra","mud"].has(currentPlanet.type["type"]) and currentPlanet.hasAtmosphere:
				world.set_block(pos,layer,1)
			elif !["snow_terra"].has(currentPlanet.type["type"]):
				world.set_block(pos,layer,2)
