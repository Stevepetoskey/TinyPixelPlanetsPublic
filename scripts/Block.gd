extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")
const FALL_BLOCKS : Array = [0,117]

var falling : bool = false
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
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	match id:
		1,24:
			$check.start(randf_range(10,60))
		9:
			var isSnow = ""
			if ["snow","snow_terra"].has(StarSystem.find_planet_id(Global.currentPlanet).type["type"]):
				isSnow = "_snow"
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/big_tree"+ isSnow+".png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			position.x += 0.5
			position.y -= 23
		6,7:
			$CollisionShape2D.disabled = true
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
		76:
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/exotic_tree1.png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			position.y -= 21
		11:
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/sapling.png")
			$check.start(randf_range(120,600))
		85:
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/exotic_sapling.png")
			$check.start(randf_range(120,600))
		20:
			$Sprite2D.texture = load("res://textures/blocks/glass_atlas.png")
			$Sprite2D.region_enabled = true
		80:
			$Sprite2D.texture = load("res://textures/blocks/wood_window_atlas.png")
			$Sprite2D.region_enabled = true
		81:
			$Sprite2D.texture = load("res://textures/blocks/copper_window_atlas.png")
			$Sprite2D.region_enabled = true
		91:
			if data.is_empty():
				data = []
		117:
			collision_layer = 32
			$Sprite2D.modulate = Color("#93ccfebb")
			update_water_texture()
		119:
			main.connect("weather_changed", Callable(self, "weather_changed"))
			if ["rain","showers","snow","blizzard"].has(main.currentWeather):
				$check.start(randf_range(10,30))
		121,122,123:
			position.y -= 3
			$CollisionShape2D.disabled = true
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			var plant = {121:"wheat",122:"tomato",123:"corn"}[id]
			if data.has("tick_wait"):
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant +"/" + plant + "_stage_" + str(data["plant_stage"]) + ".png")
				if data["plant_stage"] < 3:
					$Tick.start()
			else:
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant+"/"+ plant+"_stage_0.png")
				data["tick_wait"] = int(randf_range(600,700))
				data["plant_stage"] = 0
				$Tick.start()
		128:
			position.y -= 4
			$CollisionShape2D.disabled = true
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
		142:
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/posters/propaganda_poster1.png")
		143:
			$CollisionShape2D.disabled = true
			$Sprite2D.texture = load("res://textures/blocks/posters/propaganda_poster2.png")

func world_loaded():
	on_update()

func weather_changed(weather):
	if ["rain","showers","snow","blizzard"].has(weather):
		$check.start(randf_range(10,30))

func update_water_texture(noTop : bool = false):
	if data["water_level"] > 0:
		if world.get_block_id(pos-Vector2(0,1),layer) == 117 and !noTop:
			$Sprite2D.texture = load("res://textures/blocks/water/water_bottom.png")
		else:
			$Sprite2D.texture = load("res://textures/blocks/water/water_" + str(data["water_level"]) + ".png")

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
							var shade = Sprite2D.new()
							shade.texture = SHADE_TEX
							shade.name = str(x) + str(y)
							shade.rotation = deg_to_rad({Vector2(0,1):0,Vector2(-1,0):90,Vector2(0,-1):180,Vector2(1,0):270}[Vector2(x,y)])
							$shade.add_child(shade)
						elif world.get_block_id(pos + Vector2(x,y),1) == 0 and $shade.has_node(str(x) + str(y)):
							$shade.get_node(str(x) + str(y)).queue_free()
	
	if world.worldLoaded and visible:
		match id:
			6,7:
				var bottomBlock = world.get_block_id(pos+Vector2(0,1),layer)
				if ![1,2].has(bottomBlock):
					world.build_event("Break", pos, layer)
			10:
				if world.get_block_id(pos - Vector2(0,1),layer) == 10 or world.get_block_id(pos + Vector2(0,1),layer) == 10:
					$Sprite2D.texture = load("res://textures/blocks/log_v.png")
				elif world.get_block_id(pos - Vector2(1,0),layer) == 10 or world.get_block_id(pos + Vector2(1,0),layer) == 10:
					$Sprite2D.texture = load("res://textures/blocks/log_h.png")
				else:
					$Sprite2D.texture = load("res://textures/blocks/log_front.png")
			77:
				if world.get_block_id(pos - Vector2(0,1),layer) == 77 or world.get_block_id(pos + Vector2(0,1),layer) == 77:
					$Sprite2D.texture = load("res://textures/blocks/exotic_log_v.png")
				elif world.get_block_id(pos - Vector2(1,0),layer) == 77 or world.get_block_id(pos + Vector2(1,0),layer) == 77:
					$Sprite2D.texture = load("res://textures/blocks/exotic_log_h.png")
				else:
					$Sprite2D.texture = load("res://textures/blocks/exotic_log_front.png")
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
				var textures = {[false,false]:"res://textures/blocks/platform_full.png",[false,true]:"res://textures/blocks/platform_left.png",[true,false]:"res://textures/blocks/platform_right.png",[true,true]:"res://textures/blocks/platform_mid.png"}
				var around = [world.get_block_id(pos - Vector2(1,0),layer) == 30,world.get_block_id(pos + Vector2(1,0),layer) == 30]
				$Sprite2D.texture = load(textures[around])
			20:
				var sides = {"left":world.get_block_id(pos - Vector2(1,0),layer) == 20,"right":world.get_block_id(pos + Vector2(1,0),layer) == 20,"top":world.get_block_id(pos - Vector2(0,1),layer) == 20,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == 20}
				var sideEqual = {[true,true,true,true]:Vector2(16,8),[true,false,true,true]:Vector2(24,8),[false,true,true,true]:Vector2(8,8),[true,true,false,true]:Vector2(16,0),[true,true,true,false]:Vector2(16,16),[false,true,false,true]:Vector2(8,0),[false,true,true,false]:Vector2(8,16),[true,false,false,true]:Vector2(24,0),[true,false,true,false]:Vector2(24,16)}
				if sideEqual.has(sides.values()):
					$Sprite2D.region_rect.position = sideEqual[sides.values()]
				else:
					$Sprite2D.region_rect.position = Vector2(0,16)
			79,80:
				var sides = get_sides(id)
				if sides["top"] and sides["right"] and sides["rightTop"]:
					$Sprite2D.region_rect.position = Vector2(0,8)
				elif sides["top"] and sides["left"] and sides["leftTop"] and !sides["right"]:
					$Sprite2D.region_rect.position = Vector2(8,8)
				elif sides["right"] and sides["bottom"] and sides["bottomRight"] and !sides["top"]:
					$Sprite2D.region_rect.position = Vector2(0,0)
				else:
					$Sprite2D.region_rect.position = Vector2(8,0)
			81:
				var sides = get_sides(81)
				var sideToCheck = [sides["bottom"],sides["right"],sides["top"]]
				var sideCheck = {[false,true,true]:Vector2(8,16),[true,true,true]:Vector2(8,8),[true,true,false]:Vector2(8,0),
				[true,false,false]:Vector2(16,0),[true,false,true]:Vector2(16,8),[false,false,true]:Vector2(16,16)}
				if sideCheck.has(sideToCheck):
					$Sprite2D.region_rect.position = sideCheck[sideToCheck]
				else:
					$Sprite2D.region_rect.position = Vector2(0,16)
			117:
				var activate = false
				var moves = [pos+Vector2(0,1),pos+Vector2(1,0),pos-Vector2(1,0)]
				var id = 0
				for move in moves:
					if move.x >= 0 and move.x < world.worldSize.x and move.y < world.worldSize.y:
						var levelTest = 4 if id == 0 else data["water_level"]
						var block = world.get_block(move,layer)
						if block == null or (block.id == 117 and block.data["water_level"] < levelTest) or block.id == 119:
							activate = true
					id += 1
				if activate and !world.waterUpdateList.has(self):
					world.waterUpdateList.append(self)
				elif !activate and world.waterUpdateList.has(self):
					world.waterUpdateList.erase(self)
				update_water_texture()
			121,122,123:
				var bottomBlock = world.get_block(pos+Vector2(0,1),layer)
				if bottomBlock == null:
					world.build_event("Break", pos, layer)
				elif bottomBlock.id == 120:
					if data["tick_wait"] <= 0 and data["plant_stage"] < 3:
						data["tick_wait"] = int(randf_range(600,700))
						$Tick.start()
			128:
				$Sprite2D.texture = load("res://textures/blocks/plants/fig_tree.png")
				var bottomBlock = world.get_block_id(pos+Vector2(0,1),layer)
				if ![1,2].has(bottomBlock):
					world.build_event("Break", pos, layer)

func get_sides(blockId : int) -> Dictionary:
	return {"left":world.get_block_id(pos - Vector2(1,0),layer) == blockId,"right":world.get_block_id(pos + Vector2(1,0),layer) == blockId,"top":world.get_block_id(pos - Vector2(0,1),layer) == blockId,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == blockId,"rightTop":world.get_block_id(pos + Vector2(1,-1),layer) == blockId,"leftTop":world.get_block_id(pos - Vector2(1,1),layer) == blockId,"bottomRight":world.get_block_id(pos + Vector2(1,1),layer) == blockId}

func _on_Tick_timeout():
	match id:
		18,14:
			if [18,14].has(world.get_block_id(pos+ Vector2(2,0),layer)) and world.get_block(pos+ Vector2(2,0),layer).falling:
				await get_tree().idle_frame
			match world.get_block_id(fallPos,layer):
				0:
					world.set_block(fallPos,layer,id)
					world.set_block(pos,layer,0,true)
				117:
					world.set_block(pos,layer,0)
					world.set_block(pos,layer,117,true,{"water_level":world.get_block(fallPos,layer).data["water_level"]})
					world.set_block(fallPos,layer,0)
					world.set_block(fallPos,layer,id,true)
			falling = false
		117:
			var moves = [pos+Vector2(1,0),pos-Vector2(1,0)]
			var changed = false
			moves.shuffle()
			moves.insert(0,pos+Vector2(0,1))
			var changedTo = null
			for move in moves:
				if move.x >= 0 and move.x < world.worldSize.x and move.y < world.worldSize.y:
					var blockAt = world.get_block(move,layer)
					if blockAt == null:
						world.set_block(move,layer,117,false,{"water_level":1})
						changedTo = move
						data["water_level"] -= 1
						changed = true
						break
					elif blockAt.id == 119:
						world.set_block(move,layer,120,true)
						data["water_level"] -= 1
						changed = true
						break
					elif blockAt.id == 117 and ((blockAt.data["water_level"] < data["water_level"]) or (move == pos+Vector2(0,1) and blockAt.data["water_level"] < 4)):
						blockAt.data["water_level"] += 1
						data["water_level"] -= 1
						changed = true
						changedTo = move
						blockAt.update_water_texture()
						break
			if data["water_level"] <= 0:
				world.set_block(pos,layer,0)
				if changedTo != null:
					world.get_block(changedTo,layer).update_water_texture(true)
			elif changed:
				update_water_texture()
		121,122,123:
			data["tick_wait"] -= 1
			if data["tick_wait"] <= 0:
				data["plant_stage"] += 1
				world.set_block(pos+Vector2(0,1),layer,119)
				$Tick.stop()
				var plant = {121:"wheat",122:"tomato",123:"corn"}[id]
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant+"/"+ plant+"_stage_" + str(data["plant_stage"]) + ".png")

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
		119:
			if ["rain","showers","snow","blizzard"].has(main.currentWeather):
				world.set_block(pos,layer,120,true)
			else:
				$check.stop()
