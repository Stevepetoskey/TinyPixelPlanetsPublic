extends BaseBlock

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var rain_col: LightOccluder2D = $RainCol
@onready var mainCol: CollisionShape2D = $CollisionShape2D

func _ready():
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
		rain_col.queue_free()
		z_index -= 1
	
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	$Sprite2D.modulate = Color("#93ccfebb")
	update_water_texture()

func world_loaded():
	on_update()

func update_water_texture(noTop : bool = false):
	if data["water_level"] > 0:
		if world.get_block_id(pos-Vector2(0,1),layer) == 117 and !noTop:
			$Sprite2D.texture = load("res://textures/blocks/water/water_bottom.png")
		else:
			$Sprite2D.texture = load("res://textures/blocks/water/water_" + str(data["water_level"]) + ".png")

func on_update():
	if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
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

func get_sides(blockId : int) -> Dictionary:
	return {"left":world.get_block_id(pos - Vector2(1,0),layer) == blockId,"right":world.get_block_id(pos + Vector2(1,0),layer) == blockId,"top":world.get_block_id(pos - Vector2(0,1),layer) == blockId,"bottom":world.get_block_id(pos + Vector2(0,1),layer) == blockId,"rightTop":world.get_block_id(pos + Vector2(1,-1),layer) == blockId,"leftTop":world.get_block_id(pos - Vector2(1,1),layer) == blockId,"bottomRight":world.get_block_id(pos + Vector2(1,1),layer) == blockId}

func _on_Tick_timeout():
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

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass
