extends Area2D

const GRAVITY : float = 1.0

@onready var world = $"../../World"

var motion : Vector2

func _physics_process(delta):
	motion.y += GRAVITY
	position += motion
	if position.y > world.worldSize.y*8:
		queue_free()

func _on_Spray_body_entered(body):
	if body.id == 119:
		world.set_block(body.pos,body.layer,120)
	queue_free()
