extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var mainCol: CollisionShape2D = $CollisionShape2D

func _ready():
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		z_index -= 1
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))
	if data.has("text"):
		$Sprite2D.texture = load("res://textures/blocks/sign.png") if data["locked"] else load("res://textures/blocks/sign_empty.png")
	else:
		$Sprite2D.texture = load("res://textures/blocks/sign_empty.png")
		data = {"text":"","locked":false,"text_color":Color.WHITE,"mode":"Click","radius":2}
	mainCol.shape.size = Vector2(data["radius"]*16,data["radius"]*16)

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
