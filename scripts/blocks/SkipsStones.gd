extends BaseBlock

onready var animations = $AnimationPlayer

func _ready():
	animations.play("idle")
