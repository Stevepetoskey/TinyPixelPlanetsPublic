extends BaseBlock

onready var animations = $AnimationPlayer

func _ready():
	position.y -= 4
	animations.play("idle")
