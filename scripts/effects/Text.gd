extends Label

const GRAVITY = 0.25

var motion = Vector2(0,0)

func _ready():
	randomize()
	var dir = deg_to_rad(randf_range(45,135))
	motion = Vector2(cos(dir)*randf_range(1,3),sin(dir)*randf_range(-5,-2))

func _physics_process(delta):
	motion.y += GRAVITY
	position += motion


func _on_Timer_timeout():
	queue_free()
