extends Panel

var selectedLogicBlock : LogicBlock

@onready var logic_btns: HBoxContainer = $LogicBtns

func _ready() -> void:
	for btn : TextureButton in logic_btns.get_children():
		btn.pressed.connect(logic_btn_pressed.bind(btn.name))

func pop_up(logicBlock : LogicBlock) -> void:
	Global.pause = true
	selectedLogicBlock = logicBlock
	set_mode(logicBlock.data["mode"])
	show()

func set_mode(mode : String) -> void:
	selectedLogicBlock.change_mode(mode)
	for btn : TextureButton in logic_btns.get_children():
		btn.button_pressed = btn.name == mode

func logic_btn_pressed(mode : String) -> void:
	if is_instance_valid(selectedLogicBlock) and mode != selectedLogicBlock.data["mode"]:
		set_mode(mode)

func _on_done_btn_pressed() -> void:
	hide()
	Global.pause = false
