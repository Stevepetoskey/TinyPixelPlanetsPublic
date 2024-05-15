extends State

const GRAVITY = 4

@onready var body: AnimatedSprite2D = $"../../Body"

func enter():
	pass

func exit():
	pass

func update():
	pass

func physics_update():
	mainBody.velocity.y += GRAVITY
	if mainBody.is_on_floor():
		body.play("land")
		await body.animation_finished
		state_machine.transistion_state(self,$"../Idle")
