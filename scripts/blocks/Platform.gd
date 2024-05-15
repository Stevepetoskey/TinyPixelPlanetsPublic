extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var mainCol: CollisionShape2D = $platform

func _ready():
	collision_layer = 4
	
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
		z_index -= 1
	
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func world_loaded():
	on_update()

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
	
	if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
		var textures = {[false,false]:"res://textures/blocks/platform_full.png",[false,true]:"res://textures/blocks/platform_left.png",[true,false]:"res://textures/blocks/platform_right.png",[true,true]:"res://textures/blocks/platform_mid.png"}
		var around = [world.get_block_id(pos - Vector2(1,0),layer) == 30,world.get_block_id(pos + Vector2(1,0),layer) == 30]
		$Sprite2D.texture = load(textures[around])

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass
