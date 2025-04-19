extends BaseBlock
class_name GhostBlock

var mainBlockLoc : Vector2

func _ready():
	pos = position / world.BLOCK_SIZE
	await get_tree().process_frame
	var mainBlock = world.get_block(mainBlockLoc,layer)
	destroyed.connect(mainBlock.ghost_block_block_destroyed)
	print(mainBlock)
	mainBlock.destroyed.connect(main_block_destroyed)

func main_block_destroyed():
	world.set_block(pos,layer,0,true)

func on_update():
	pass
