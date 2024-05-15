extends GPUParticles2D

func _ready():
	emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
