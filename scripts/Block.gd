extends StaticBody2D

const SHADE_TEX = preload("res://textures/blocks2X/shade.png")
const water_textures = {"bottom":preload("res://textures/blocks2X/water/water_bottom.png"),
0:preload("res://textures/blocks2X/debug.png"),
1:preload("res://textures/blocks2X/water/water_1.png"),
2:preload("res://textures/blocks2X/water/water_2.png"),
3:preload("res://textures/blocks2X/water/water_3.png"),
4:preload("res://textures/blocks2X/water/water_4.png")
}
const FALL_BLOCKS = [0,117]

export var id = 1
export var layer = 1

onready var world = get_node("../..")

var data = {}
var pos : Vector2

var falling = false
var fallPos : Vector2

var water_level = 4

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
		$LightOccluder2D.queue_free()
		$Sprite.light_mask = 1
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
			$Sprite.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite.material.set_shader_param("offset",position.x/8.0)
			position.x += 0.5
			position.y -= 23
		6,7:
			$CollisionShape2D.disabled = true
			$Sprite.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite.material.set_shader_param("offset",position.x/8.0)
		76:
			$CollisionShape2D.disabled = true
			$Sprite.texture = load("res://textures/blocks2X/exotic_tree1.png")
			$Sprite.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite.material.set_shader_param("offset",position.x/8.0)
			position.y -= 21
		11:
			$CollisionShape2D.disabled = true
			$Sprite.texture = load("res://textures/blocks2X/sapling.png")
			$check.start(rand_range(120,600))
		85:
			$CollisionShape2D.disabled = true
			$Sprite.texture = load("res://textures/blocks2X/exotic_sapling.png")
			$check.start(rand_range(120,600))
		20:
			$Sprite.texture = load("res://textures/blocks2X/glass_atlas.png")
			$Sprite.region_enabled = true
		80:
			$Sprite.texture = load("res://textures/blocks2X/wood_window_atlas.png")
			$Sprite.region_enabled = true
		81:
			$Sprite.texture = load("res://textures/blocks2X/copper_window_atlas.png")
			$Sprite.region_enabled = true
		91:
			if data.empty():
				data = []
		117:
			$Sprite.modulate = Color("c74fa0ef")
			if layer == 1:
				z_index = 10
			collision_layer = 32
			if data.has("water_level"):
				water_level = data["water_level"]
			if world.get_block_id(pos-Vector2(0,1),layer) == 117:
				$Sprite.texture = water_textures["bottom"]
			else:
				$Sprite.texture = water_textures[water_level]

func world_loaded():
	on_update()

func on_update():
	if layer < 1:
		if world.transparentBlocks.has(world.get_block_id(pos,1)) and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
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
			77:
				if world.get_block_id(pos - Vector2(0,1),layer) == 77 or world.get_block_id(pos + Vector2(0,1),layer) == 77:
					$Sprite.texture = load("res://textures/blocks2X/exotic_log_v.png")
				elif world.get_block_id(pos - Vector2(1,0),layer) == 77 or world.get_block_id(pos + Vector2(1,0),layer) == 77:
					$Sprite.texture = load("res://textures/blocks2X/exotic_log_h.png")
				else:
					$Sprite.texture = load("res://textures/blocks2X/exotic_log_front.png")
			18,14:
				if !falling and pos.y < world.worldSize.y -1:
					if pos.y < world.worldSize.y - 1 and FALL_BLOCKS.has(world.get_block_id(pos + Vector2(0,1),layer)):
						falling = true
						fallPos = pos + Vector2(0,1)
						$Tick.start()
					elif world.get_block_id(pos + Vector2(0,1),layer) == id:
						if pos.x < world.worldSize.x - 1 and FALL_BLOCKS.has(world.get_block_id(pos + Vector2(1,1),layer)):
							falling = true
							fallPos = pos + Vector2(1,1)
							$Tick.start()
						elif pos.x > 0 and FALL_BLOCKS.has(world.get_block_id(pos + Vector2(-1,1),layer)):
							falling = true
							fallPos = pos + Vector2(-1,1)
							$Tick.start()
			30:
				var textures = {[false,false]:"res://textures/blocks2X/platform_full.png",[false,true]:"res://textures/blocks2X/platform_left.png",[true,false]:"res://textures/blocks2X/platform_right.png",[true,true]:"res://textures/blocks2X/platform_mid.png"}
				var around = [world.get_block_id(pos - Vector2(1,0),layer) == 30,world.get_block_id(pos + Vector2(1,0),layer) == 30]
				$Sprite.texture = load(textures[around])
			20:
				var sides = {"left":world.get_block_id(pos - Vector2(1,0),layer) == 20,"right":world.get_block_id(pos + Vector2(1,0),layer) == 20,"top":world.get_block_id(pos - Vector2(0,1),layer) == 20,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == 20}
				var sideEqual = {[true,true,true,true]:Vector2(16,8),[true,false,true,true]:Vector2(24,8),[false,true,true,true]:Vector2(8,8),[true,true,false,true]:Vector2(16,0),[true,true,true,false]:Vector2(16,16),[false,true,false,true]:Vector2(8,0),[false,true,true,false]:Vector2(8,16),[true,false,false,true]:Vector2(24,0),[true,false,true,false]:Vector2(24,16)}
				if sideEqual.has(sides.values()):
					$Sprite.region_rect.position = sideEqual[sides.values()]
				else:
					$Sprite.region_rect.position = Vector2(0,16)
			79,80:
				var sides = get_sides(id)
				if sides["top"] and sides["right"] and sides["rightTop"]:
					$Sprite.region_rect.position = Vector2(0,8)
				elif sides["top"] and sides["left"] and sides["leftTop"] and !sides["right"]:
					$Sprite.region_rect.position = Vector2(8,8)
				elif sides["right"] and sides["bottom"] and sides["bottomRight"] and !sides["top"]:
					$Sprite.region_rect.position = Vector2(0,0)
				else:
					$Sprite.region_rect.position = Vector2(8,0)
			81:
				var sides = get_sides(81)
				var sideToCheck = [sides["bottom"],sides["right"],sides["top"]]
				var sideCheck = {[false,true,true]:Vector2(8,16),[true,true,true]:Vector2(8,8),[true,true,false]:Vector2(8,0),
				[true,false,false]:Vector2(16,0),[true,false,true]:Vector2(16,8),[false,false,true]:Vector2(16,16)}
				if sideCheck.has(sideToCheck):
					$Sprite.region_rect.position = sideCheck[sideToCheck]
				else:
					$Sprite.region_rect.position = Vector2(0,16)
			117:
				if world.get_block_id(pos-Vector2(0,1),layer) == 117:
					$Sprite.texture = water_textures["bottom"]
				else:
					if [0,1,2,3,4].has(water_level):
						$Sprite.texture = water_textures[water_level]
					else:
						$Sprite.texture = water_textures[0]
				var activate = false
				var blocks = {Vector2(0,1):world.get_block(pos+Vector2(0,1),layer),Vector2(-1,0):world.get_block(pos-Vector2(1,0),layer),Vector2(1,0):world.get_block(pos+Vector2(1,0),layer)}
				for aroundPos in blocks:
					var aroundId = 0 if blocks[aroundPos] == null else blocks[aroundPos].id
					if (aroundPos != Vector2(-1,0) or pos.x > 0) and (aroundPos != Vector2(0,1) or pos.y < world.worldSize.y - 1) and (aroundPos != Vector2(1,0) or pos.x < world.worldSize.x - 1) and (aroundId == 0 or (aroundId == 117 and blocks[aroundPos].water_level < 4)):
						activate = true
						break
				if activate:
					if $Tick.time_left <= 0:
						$Tick.start()
				else:
					$Tick.stop()

#func _process(delta):
#	if water_level <= 0:
#		queue_free()

func get_sides(blockId : int) -> Dictionary:
	return {"left":world.get_block_id(pos - Vector2(1,0),layer) == blockId,"right":world.get_block_id(pos + Vector2(1,0),layer) == blockId,"top":world.get_block_id(pos - Vector2(0,1),layer) == blockId,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == blockId,"rightTop":world.get_block_id(pos + Vector2(1,-1),layer) == blockId,"leftTop":world.get_block_id(pos - Vector2(1,1),layer) == blockId,"bottomRight":world.get_block_id(pos + Vector2(1,1),layer) == blockId}

func _on_Tick_timeout():
	match id:
		18,14:
			if world.get_block(pos+ Vector2(2,0),layer) != null and world.get_block(pos+ Vector2(2,0),layer).falling:
				yield(get_tree(),"idle_frame")
			match world.get_block_id(fallPos,layer):
				0:
					world.set_block(fallPos,layer,id)
					world.set_block(pos,layer,0,true)
				117:
					world.set_block(pos,layer,0)
					world.set_block(pos,layer,117,true,{"water_level":world.get_block(fallPos,layer).water_level})
					world.set_block(fallPos,layer,0)
					world.set_block(fallPos,layer,id,true)
			falling = false
		117:
			if world.get_block_id(pos + Vector2(0,1),layer) == 0 and pos.y < world.worldSize.y-1:
				world.set_block(pos + Vector2(0,1),layer,117,true,{"water_level":1})
				water_level -= 1
			elif world.get_block_id(pos+Vector2(0,1),layer) == 117 and world.get_block(pos+Vector2(0,1),layer).water_level < 4:
				world.get_block(pos+Vector2(0,1),layer).water_level += 1
				water_level -= 1
				world.update_area(pos)
			else:
				var leftLevel = 0 if world.get_block_id(pos - Vector2(1,0),layer) == 0 and pos.x > 0 else 4
				if world.get_block_id(pos-Vector2(1,0),layer) == 117:
					leftLevel = world.get_block(pos-Vector2(1,0),layer).water_level
				var rightLevel = 0 if world.get_block_id(pos + Vector2(1,0),layer) == 0 and pos.x < world.worldSize.x-1 else 4
				if world.get_block_id(pos+Vector2(1,0),layer) == 117:
					rightLevel = world.get_block(pos+Vector2(1,0),layer).water_level
				var otherLevel = leftLevel if (leftLevel < rightLevel and leftLevel != rightLevel) or (leftLevel == rightLevel and randi()%2==1) else rightLevel
				var otherPos = Vector2(-1,0) if (leftLevel < rightLevel and leftLevel != rightLevel) or (leftLevel == rightLevel and randi()%2==1) else Vector2(1,0)
				if otherLevel < water_level:
					if otherLevel == 0:
						world.set_block(pos + otherPos,layer,117,true,{"water_level":1})
						water_level -= 1
					elif otherLevel < 4:
						world.get_block(pos+otherPos,layer).water_level += 1
						water_level -= 1
						world.update_area(pos)
			if water_level <= 0:
				world.set_block(pos,layer,0,true)
			elif world.get_block_id(pos-Vector2(0,1),layer) == 117:
				$Sprite.texture = water_textures["bottom"]
			else:
				$Sprite.texture = water_textures[water_level]

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
		11:
			world.set_block(pos,layer,9)
		85:
			world.set_block(pos,layer,76)
