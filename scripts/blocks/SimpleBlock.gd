extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var mainCol : CollisionShape2D = $CollisionShape2D

func _ready():
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
	z_index = layer
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "on_update"))

func on_update():
	if layer < 1:
		var blockLayer1 = world.get_block_id(pos,1)
		if world.transparentBlocks.has(blockLayer1) and ([0,10,77].has(blockLayer1) or id != blockLayer1):
			show()
		else:
			hide()
		if world.worldLoaded and visible:
			for x in range(-1,2):
				for y in range(-1,2):
					if abs(x) != abs(y):
						if ![0,6,7,9,30,117].has(world.get_block_id(pos + Vector2(x,y),1)) and !$shade.has_node(str(x) + str(y)):
							var shade = Sprite2D.new()
							shade.texture = SHADE_TEX
							shade.name = str(x) + str(y)
							shade.rotation = deg_to_rad({Vector2(0,1):0,Vector2(-1,0):90,Vector2(0,-1):180,Vector2(1,0):270}[Vector2(x,y)])
							$shade.add_child(shade)
						elif world.get_block_id(pos + Vector2(x,y),1) == 0 and $shade.has_node(str(x) + str(y)):
							$shade.get_node(str(x) + str(y)).queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
