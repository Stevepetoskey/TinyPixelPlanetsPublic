extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")
const PLATFORM_TEXTURES = {30:"res://textures/blocks/platform_",188:"res://textures/blocks/scorched_platform_",204:"res://textures/blocks/permafrost_platform_",329:"res://textures/blocks/acacia_platform_",330:"res://textures/blocks/exotic_platform_",331:"res://textures/blocks/willow_platform_",332:"res://textures/blocks/smooth_stone_platform_",333:"res://textures/blocks/mud_stone_platform_"}

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var mainCol: CollisionShape2D = $platform

func _ready():
	collision_layer = 4
	
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
		z_index -= 1
	if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
		var textures = PLATFORM_TEXTURES
		var side = {[true,true]:"full",[true,false]:"left",[false,true]:"right",[false,false]:"mid"}
		var around = [!GlobalData.blockData[world.get_block_id(pos - Vector2(1,0),layer)]["transparent"],!GlobalData.blockData[world.get_block_id(pos + Vector2(1,0),layer)]["transparent"]]
		$Sprite2D.texture = load(textures[id] + side[around] + ".png")
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func world_loaded():
	on_update()

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
	if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
		var textures = PLATFORM_TEXTURES
		var side = {[true,true]:"full",[true,false]:"left",[false,true]:"right",[false,false]:"mid"}
		var around = [!GlobalData.blockData[world.get_block_id(pos - Vector2(1,0),layer)]["transparent"],!GlobalData.blockData[world.get_block_id(pos + Vector2(1,0),layer)]["transparent"]]
		$Sprite2D.texture = load(textures[id] + side[around] + ".png")

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass
