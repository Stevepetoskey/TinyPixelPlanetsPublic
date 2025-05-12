extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")
const FALL_BLOCKS : Array = [0,117]

var falling : bool = false
var fallPos : Vector2

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var rain_col: LightOccluder2D = $RainCol
@onready var mainCol: CollisionShape2D = $CollisionShape2D
@onready var texture: Sprite2D = $Sprite2D

func _ready():
	z_index = layer
	if layer < 1 or !GlobalData.get_item_data(id)["can_collide"]:
		mainCol.disabled = true
		rain_col.queue_free()
		if layer < 1:
			modulate = Color(0.68,0.68,0.68)
			z_index -= 1
	
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	match id:
		1,24,146:
			$check.start(randf_range(10,60))
		20:
			texture.texture = load("res://textures/blocks/glass_atlas.png")
			texture.region_enabled = true
		79:
			texture.texture = load("res://textures/blocks/exotic_wood_window_atlas.png")
			texture.region_enabled = true
		80:
			texture.texture = load("res://textures/blocks/wood_window_atlas.png")
			texture.region_enabled = true
		81:
			texture.texture = load("res://textures/blocks/copper_window_atlas.png")
			texture.region_enabled = true
		91,159:
			if data.is_empty():
				data = []
		119:
			main.connect("weather_changed", Callable(self, "weather_changed"))
			if ["rain","showers","snow","blizzard"].has(main.currentWeather):
				$check.start(randf_range(10,30))
		145:
			if data.has("text"):
				texture.texture = load("res://textures/blocks/sign.png") if data["locked"] else load("res://textures/blocks/sign_empty.png")
			else:
				texture.texture = load("res://textures/blocks/sign_empty.png")
				data = {"text":"","locked":false,"text_color":Color.WHITE,"mode":"Click","radius":2}
		173:
			texture.texture = load("res://textures/blocks/steel_atlas.png")
			texture.region_enabled = true
		180:
			texture.texture = load("res://textures/blocks/scorched_bricks_1.png") if fmod(pos.y,2.0) == 0 else load("res://textures/blocks/scorched_bricks_2.png")
		183,203,334,335,336:
			texture.texture = load({183:"res://textures/blocks/scorched_brick_fence_atlas.png",203:"res://textures/blocks/permafrost_fence_atlas.png",334:"res://textures/blocks/planks_fence_atlas.png",335:"res://textures/blocks/willow_planks_fence_atlas.png",336:"res://textures/blocks/acacia_planks_fence_atlas.png"}[id])
			texture.region_enabled = true
		185:
			if data.is_empty():
				data["group"] = ""
		189:
			if data.is_empty():
				data["group"] = ""
		273:
			texture.texture = load("res://textures/blocks/quartz_bricks_1.png") if fmod(pos.x,2.0) == 0 else load("res://textures/blocks/quartz_bricks_2.png")
		274:
			texture.texture = load("res://textures/blocks/rose_quartz_bricks_1.png") if fmod(pos.x,2.0) == 0 else load("res://textures/blocks/rose_quartz_bricks_2.png")
		275:
			texture.texture = load("res://textures/blocks/purple_quartz_bricks_1.png") if fmod(pos.x,2.0) == 0 else load("res://textures/blocks/purple_quartz_bricks_2.png")
		276:
			texture.texture = load("res://textures/blocks/blue_quartz_bricks_1.png") if fmod(pos.x,2.0) == 0 else load("res://textures/blocks/blue_quartz_bricks_2.png")
		282:
			texture.texture = load("res://textures/blocks/smooth_stone_bricks_1.png") if fmod(pos.y,2.0) == 0 else load("res://textures/blocks/smooth_stone_bricks_2.png")
		320:
			if data.is_empty():
				data = {"fuel":{"id":0,"amount":0,"data":{}},"cooks_left":0,"max_fuel":0}
		328:
			texture.texture = load("res://textures/blocks/tech_workbench.png")
			texture.position += Vector2(4,4)

func world_loaded():
	on_update()

func weather_changed(weather):
	if ["rain","showers","snow","blizzard"].has(weather) and [1,24,146,119].has(id):
		$check.start(randf_range(10,30))

func on_update():
	if layer < 1:
		if GlobalData.blockData[world.get_block_id(pos,1)]["transparent"] and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
			show()
		else:
			hide()
		if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
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
	
	if world.worldLoaded and (visible_on_screen_notifier_2d.is_on_screen() or [14,18].has(id)):
		match id:
			10,77,154,297: #logs
				if world.get_block_id(pos - Vector2(0,1),layer) == id or world.get_block_id(pos + Vector2(0,1),layer) == id:
					texture.texture = {10:load("res://textures/blocks/log_v.png"),77:load("res://textures/blocks/exotic_log_v.png"),154:load("res://textures/blocks/acacia_log_v.png"),297:load("res://textures/blocks/willow_log_v.png")}[id]
				elif world.get_block_id(pos - Vector2(1,0),layer) == id or world.get_block_id(pos + Vector2(1,0),layer) == id:
					texture.texture = {10:load("res://textures/blocks/log_h.png"),77:load("res://textures/blocks/exotic_log_h.png"),154:load("res://textures/blocks/acacia_log_h.png"),297:preload("res://textures/blocks/willow_log_h.png")}[id]
				else:
					texture.texture = {10:load("res://textures/blocks/log_front.png"),77:load("res://textures/blocks/exotic_log_front.png"),154:load("res://textures/blocks/acacia_log_front.png"),297:preload("res://textures/blocks/willow_log_front.png")}[id]
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
			20:
				var sides = {"left":world.get_block_id(pos - Vector2(1,0),layer) == 20,"right":world.get_block_id(pos + Vector2(1,0),layer) == 20,"top":world.get_block_id(pos - Vector2(0,1),layer) == 20,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == 20}
				var sideEqual = {[true,true,true,true]:Vector2(16,8),[true,false,true,true]:Vector2(24,8),[false,true,true,true]:Vector2(8,8),[true,true,false,true]:Vector2(16,0),[true,true,true,false]:Vector2(16,16),[false,true,false,true]:Vector2(8,0),[false,true,true,false]:Vector2(8,16),[true,false,false,true]:Vector2(24,0),[true,false,true,false]:Vector2(24,16)}
				if sideEqual.has(sides.values()):
					texture.region_rect.position = sideEqual[sides.values()]
				else:
					texture.region_rect.position = Vector2(0,16)
			79,80:
				var sides = get_sides(id)
				if sides["top"] and sides["right"] and sides["rightTop"]:
					texture.region_rect.position = Vector2(0,8)
				elif sides["top"] and sides["left"] and sides["leftTop"] and !sides["right"]:
					texture.region_rect.position = Vector2(8,8)
				elif sides["right"] and sides["bottom"] and sides["bottomRight"] and !sides["top"]:
					texture.region_rect.position = Vector2(0,0)
				else:
					texture.region_rect.position = Vector2(8,0)
			81:
				var sides = get_sides(81)
				var sideToCheck = [sides["bottom"],sides["right"],sides["top"]]
				var sideCheck = {[false,true,true]:Vector2(8,16),[true,true,true]:Vector2(8,8),[true,true,false]:Vector2(8,0),
				[true,false,false]:Vector2(16,0),[true,false,true]:Vector2(16,8),[false,false,true]:Vector2(16,16)}
				if sideCheck.has(sideToCheck):
					texture.region_rect.position = sideCheck[sideToCheck]
				else:
					texture.region_rect.position = Vector2(0,16)
			173:
				var choices = {[Vector2(0,-1),Vector2(1,0),Vector2(1,-1)]:{"mod":Vector2(0,1),"atlas_pos":Vector2(8,8)},[Vector2(0,1),Vector2(1,0),Vector2(1,1)]:{"mod":Vector2(0,0),"atlas_pos":Vector2(8,0)},[Vector2(0,1),Vector2(-1,0),Vector2(-1,1)]:{"mod":Vector2(1,0),"atlas_pos":Vector2(16,0)},[Vector2(0,-1),Vector2(-1,0),Vector2(-1,-1)]:{"mod":Vector2(1,1),"atlas_pos":Vector2(16,8)}}
				var sides = get_sides_vector2([173,174])
				var chosenSides = []
				for sideArray in choices.keys():
					var count = 0
					for i in sideArray:
						if sides[i]:
							count += 1
					if count >= 3:
						chosenSides.append(sideArray)
				if chosenSides.size() > 0:
					var posMod = Vector2(fmod(pos.x,2.0),fmod(pos.y,2.0))
					var correctSide : Array
					for side in chosenSides:
						if choices[side]["mod"] == posMod:
							correctSide = side
					if correctSide.is_empty():
						texture.region_rect.position = Vector2(0,8)
					else:
						texture.region_rect.position = choices[correctSide]["atlas_pos"]
				else:
					texture.region_rect.position = Vector2(0,8)
			183,203,334,335,336:
				var choices = {[false,false,false]:Vector2(16,16),[true,false,false]:Vector2(16,0),[false,true,false]:Vector2(16,16),[false,false,true]:Vector2(0,0),[true,true,false]:Vector2(16,8),[false,true,true]:Vector2(0,8),[true,false,true]:Vector2(8,0),[true,true,true]:Vector2(8,8)}
				var sides = get_sides_vector2([183,203,334,335,336],true)
				texture.region_rect.position = choices[[sides[Vector2(-1,0)],sides[Vector2(0,-1)],sides[Vector2(1,0)]]]

func get_sides(blockId : int) -> Dictionary:
	return {"left":world.get_block_id(pos - Vector2(1,0),layer) == blockId,"right":world.get_block_id(pos + Vector2(1,0),layer) == blockId,"top":world.get_block_id(pos - Vector2(0,1),layer) == blockId,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == blockId,"rightTop":world.get_block_id(pos + Vector2(1,-1),layer) == blockId,"leftTop":world.get_block_id(pos - Vector2(1,1),layer) == blockId,"bottomRight":world.get_block_id(pos + Vector2(1,1),layer) == blockId,"bottomLeft":world.get_block_id(pos + Vector2(-1,1),layer) == blockId}

func get_sides_vector2(blockIds : Array,whiteListMode : bool = false) -> Dictionary:
	var sides = {}
	for x in range(-1,2):
		for y in range(-1,2):
			if !(x==0 and y==0):
				if whiteListMode:
					sides[Vector2(x,y)] = !GlobalData.blockData[world.get_block_id(pos + Vector2(x,y),layer)]["transparent"] or blockIds.has(world.get_block_id(pos + Vector2(x,y),layer))
				else:
					sides[Vector2(x,y)] = blockIds.has(world.get_block_id(pos + Vector2(x,y),layer))
	return sides

func _on_Tick_timeout():
	match id:
		18,14:
			if [18,14].has(world.get_block_id(pos+ Vector2(2,0),layer)) and world.get_block(pos+ Vector2(2,0),layer).falling:
				await get_tree().process_frame
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

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass

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
		146:
			var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet)
			if ["desert","stone","snow","snow_terra"].has(currentPlanet.type["type"]) or !currentPlanet.hasAtmosphere:
				world.set_block(pos,layer,147)
		119:
			if ["rain","showers","snow","blizzard"].has(main.currentWeather):
				world.set_block(pos,layer,120,true)
			else:
				$check.stop()
