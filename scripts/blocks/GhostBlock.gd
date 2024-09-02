extends BaseBlock

var mainBlock : BaseBlock

signal destroyed

func _ready():
	pos = position / world.BLOCK_SIZE
	mainBlock.destroyed.connect(main_block_destroyed)

func main_block_destroyed():
	world.set_block(pos,layer,0,true)

func on_update():
	pass
