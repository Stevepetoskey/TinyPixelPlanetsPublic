extends Particles2D

func _ready():
	emitting = true
	yield(get_tree().create_timer(2.0),"timeout")
	queue_free()
