extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var rain_col: LightOccluder2D = $RainCol
@onready var mainCol: CollisionShape2D = $CollisionShape2D
@onready var texture: Sprite2D = $Sprite2D
@onready var beam: TextureRect = $Beam

func _ready():
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
		rain_col.queue_free()
		z_index -= 1
	if data.is_empty():
		data = {"magma":0,"coolant":0,"active":false}
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	world.blocks_changed.connect(blocks_changed)
	updated_data()

func updated_data() -> void:
	$MagmaBar.value = data["magma"]
	$CoolantBar.value = data["coolant"]
	$Active.visible = data["active"]
	beam.visible = data["active"]
	blocks_changed()

func world_loaded():
	on_update()

func blocks_changed() -> void:
	await get_tree().process_frame
	if data["active"]:
		if $BeamTest.is_colliding():
			beam.size.y = global_position.y - $BeamTest.get_collision_point().y - 4
		else:
			beam.size.y = 512

func on_update():
	if layer < 1:
		if world.transparentBlocks.has(world.get_block_id(pos,1)) and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
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
