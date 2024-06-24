extends TextureRect

var outputBlock : LogicBlock = null
var inputBlock : LogicBlock = null
var outputPin : String = ""
var inputPin : String = ""
var wireOffset = Vector2(2,0.5)

@onready var world: Node2D = $"../.."
@onready var cursor: Sprite2D = $"../../../Cursor"

func _ready() -> void:
	world.connect("blocks_changed",blocks_changed)

func blocks_changed():
	await get_tree().process_frame
	if !is_instance_valid(outputBlock) or !is_instance_valid(inputBlock):
		break_wire()

func setup() -> void:
	position = outputBlock.get_node("Outputs/" + outputPin).global_position + outputBlock.get_node("Outputs").offset + wireOffset
	var toPos = inputBlock.get_node("Inputs/"+ inputPin).global_position + inputBlock.get_node("Inputs").offset + wireOffset
	rotation = position.angle_to_point(toPos)
	size.x = position.distance_to(toPos)
	outputBlock.connect("output",output_called)
	outputBlock.send_output(outputPin)

func output_called(pin : String, value) -> void:
	if pin == outputPin and is_instance_valid(inputBlock):
		inputBlock.input_called(inputPin,value,self)

func break_wire():
	if is_instance_valid(inputBlock):
		inputBlock.wire_broke(inputPin,self)
	queue_free()

func _on_mouse_entered() -> void:
	cursor.wireIn.append(self)

func _on_mouse_exited() -> void:
	cursor.wireIn.erase(self)
