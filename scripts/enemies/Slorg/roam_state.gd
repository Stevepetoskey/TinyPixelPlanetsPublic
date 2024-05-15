extends State

@onready var move_timer: Timer = $MoveTimer

func enter():
	move_timer.start(randi_range(1,10))

func exit():
	move_timer.stop()

func update():
	pass

func physics_update():
	if !mainBody.is_on_floor():
		state_machine.transistion_state(self,$"../Fall")

func _on_move_timer_timeout() -> void:
	if state_machine.currentState == self:
		state_machine.transistion_state(self,$"../Jump")
