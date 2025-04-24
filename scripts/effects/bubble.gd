extends Sprite2D

const MAX_SPEED : float = 1

var motion : Vector2
var popped : bool = false

@onready var world: Node2D = $"../../World"

func _physics_process(delta: float) -> void:
	if !popped:
		if abs(motion.y) < MAX_SPEED:
			motion.y -= 0.01
		position += motion
		if world.get_block_id(Vector2i(position / world.BLOCK_SIZE),1) != 117:
			popped = true
			frame = 1
			motion.y = 0
			await get_tree().create_timer(0.1).timeout
			queue_free()
