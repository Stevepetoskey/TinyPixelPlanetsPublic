extends Label

const GRAVITY = 0.5

var motion = Vector2(0,0)

func _ready():
	randomize()
	var dir = deg2rad(rand_range(45,135))
	motion = Vector2(cos(dir)*rand_range(1,5),sin(dir)*rand_range(-7,-3))

func _physics_process(delta):
	motion.y += GRAVITY
	rect_position += motion


func _on_Timer_timeout():
	queue_free()
