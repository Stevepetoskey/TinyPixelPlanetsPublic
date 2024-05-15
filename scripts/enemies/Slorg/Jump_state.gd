extends State

const MAX_SPEED = 30
const JUMPSPEED = 75

@onready var body: AnimatedSprite2D = $"../../Body"

func enter():
	body.play("hop")
	await body.animation_finished
	if state_machine.currentState == self:
		var dir = 1 if randi()%2 == 1 else -1
		mainBody.velocity = Vector2(MAX_SPEED * dir,-JUMPSPEED)
		state_machine.transistion_state(self,$"../Fall")

func exit():
	pass

func update():
	pass

func physics_update():
	pass
