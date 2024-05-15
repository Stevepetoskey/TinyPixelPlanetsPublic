extends Node

@export var initialState : State

var currentState : State

func transistion_state(stateFrom : State,stateTo : State):
	stateFrom.exit()
	stateTo.enter()
	currentState = stateTo

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.physics_update()

func _process(delta: float) -> void:
	if currentState:
		currentState.update()
