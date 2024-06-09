extends TextureRect

var outputBlock : LogicBlock = null
var inputBlock : LogicBlock = null
var outputPin : String = ""
var inputPin : String = ""
var new : bool = false
var mouseIn : bool = false

@onready var world: Node2D = $"../.."

func _ready() -> void:
	world.connect("blocks_changed",blocks_changed)
	if !new:
		setup()

func blocks_changed():
	await get_tree().process_frame
	if !is_instance_valid(outputBlock) or !is_instance_valid(inputBlock):
		break_wire()

func setup() -> void:
	position = outputBlock.get_node("Outputs/" + outputPin).global_position + outputBlock.get_node("Outputs").offset
	print(inputBlock.get_children())
	rotation = position.angle_to_point(inputBlock.get_node("Inputs/"+ inputPin).global_position + inputBlock.get_node("Inputs").offset)
	size.x = position.distance_to(inputBlock.get_node("Inputs/"+ inputPin).global_position + inputBlock.get_node("Inputs").offset)
	outputBlock.connect("output",output_called)
	outputBlock.send_output(outputPin)

func output_called(pin : String, value) -> void:
	if pin == outputPin and is_instance_valid(inputBlock):
		inputBlock.input_called(inputPin,value,self)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("build2") and mouseIn:
		break_wire()

func break_wire():
	if is_instance_valid(inputBlock):
		inputBlock.wire_broke(inputPin,self)
	queue_free()

func _on_mouse_entered() -> void:
	mouseIn = true

func _on_mouse_exited() -> void:
	mouseIn = false
