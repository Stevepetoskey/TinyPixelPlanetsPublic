extends BaseBlock

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
	
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	match id:
		9:
			z_index -= 1
			var isSnow = ""
			if ["snow","snow_terra"].has(StarSystem.find_planet_id(Global.currentPlanet).type["type"]):
				isSnow = "_snow"
			$Sprite2D.texture = load("res://textures/blocks/big_tree"+ isSnow+".png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			position.x += 0.5
			position.y -= 23
		6,7,218:
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			$Sprite2D.texture = load({6:"res://textures/blocks/flower1.png",7:"res://textures/blocks/flower2.png",218:"res://textures/blocks/blue_mud_flower.png"}[id])
		160,220:
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
		76:
			z_index -= 1
			$Sprite2D.texture = load("res://textures/blocks/exotic_tree1.png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			position.y -= 21
		11:
			$Sprite2D.texture = load("res://textures/blocks/sapling.png")
			$check.start(randf_range(120,600))
		85:
			$Sprite2D.texture = load("res://textures/blocks/exotic_sapling.png")
			$check.start(randf_range(120,600))
		121,122,123,221:
			position.y -= 3
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			var plant = {121:"wheat",122:"tomato",123:"corn",221:"coffee"}[id]
			if data.has("tick_wait"):
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant +"/" + plant + "_stage_" + str(data["plant_stage"]) + ".png")
				if data["plant_stage"] < 3:
					$Tick.start()
			else:
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant+"/"+ plant+"_stage_0.png")
				data["tick_wait"] = int(randf_range(600,700))
				data["plant_stage"] = 0
				$Tick.start()
		128,161:
			position.y -= 4
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
		142:
			$Sprite2D.texture = load("res://textures/blocks/posters/propaganda_poster1.png")
		143:
			$Sprite2D.texture = load("res://textures/blocks/posters/propaganda_poster2.png")
		155:
			z_index -= 1
			$Sprite2D.texture = load("res://textures/blocks/plants/acacia_tree/acacia_tree_1.png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			#position.x += 0.5
			position.y -= 46
		156:
			z_index -= 1
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			$check.start(randf_range(120,600))
		187:
			modulate *= Color(1,1,1,0.5)
		196:
			$Sprite2D.texture = load("res://textures/blocks/plants/desert_bush.png")
			$Sprite2D.material = load("res://shaders/tree_shader.tres").duplicate(true)
			$Sprite2D.material.set_shader_parameter("offset",position.x/8.0)
			position.y -= 4
		217:
			var topBlock = world.get_block_id(pos-Vector2(0,1),layer)
			if [0].has(topBlock):
				world.build_event("Break", pos, layer)

func world_loaded():
	on_update()

func on_update():
	if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
		match id:
			6,7,160,161,196:
				var bottomBlock = world.get_block_id(pos+Vector2(0,1),layer)
				if !world.blockData[id]["can_place_on"].has(bottomBlock):
					world.build_event("Break", pos, layer)
			121,122,123,221:
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
			217:
				var topBlock = world.get_block_id(pos-Vector2(0,1),layer)
				if [0].has(topBlock):
					world.build_event("Break", pos, layer)

func get_sides(blockId : int) -> Dictionary:
	return {"left":world.get_block_id(pos - Vector2(1,0),layer) == blockId,"right":world.get_block_id(pos + Vector2(1,0),layer) == blockId,"top":world.get_block_id(pos - Vector2(0,1),layer) == blockId,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == blockId,"rightTop":world.get_block_id(pos + Vector2(1,-1),layer) == blockId,"leftTop":world.get_block_id(pos - Vector2(1,1),layer) == blockId,"bottomRight":world.get_block_id(pos + Vector2(1,1),layer) == blockId}

func _on_Tick_timeout():
	match id:
		121,122,123,221:
			data["tick_wait"] -= 1
			if data["tick_wait"] <= 0:
				data["plant_stage"] += 1
				world.set_block(pos+Vector2(0,1),layer,119)
				$Tick.stop()
				var plant = {121:"wheat",122:"tomato",123:"corn",221:"coffee"}[id]
				$Sprite2D.texture = load("res://textures/blocks/plants/"+ plant+"/"+ plant+"_stage_" + str(data["plant_stage"]) + ".png")

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass

func _on_check_timeout():
	match id:
		11:
			world.set_block(pos,layer,9)
		85:
			world.set_block(pos,layer,76)
		156:
			world.set_block(pos,layer,155)
