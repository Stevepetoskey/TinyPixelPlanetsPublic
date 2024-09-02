extends Panel

@onready var x_edit: SpinBox = $VBoxContainer/Position/XEdit
@onready var y_edit: SpinBox = $VBoxContainer/Position/YEdit
@onready var width_edit: SpinBox = $VBoxContainer/Size/WidthEdit
@onready var height_edit: SpinBox = $VBoxContainer/Size/HeightEdit
@onready var name_edit: LineEdit = $VBoxContainer/Name/NameEdit
@onready var save_btn: Button = $SaveBtn
@onready var world: Node2D = $"../../World"

var selectedBlock : BaseBlock

func pop_up(block : BaseBlock):
	Global.pause = true
	selectedBlock = block
	var data = selectedBlock.data
	save_btn.disabled = data["file_name"].is_empty()
	x_edit.value = data["pos"].x
	y_edit.value = data["pos"].y
	width_edit.value = data["size"].x
	height_edit.value = data["size"].y
	name_edit.text = data["file_name"]
	show()

func _on_back_btn_pressed() -> void:
	hide()
	Global.pause = false

func _on_save_btn_pressed() -> void:
	var structureRect : Rect2 = Rect2(Vector2(int(x_edit.value),int(y_edit.value)),Vector2(int(width_edit.value),int(height_edit.value)))
	var data = {"structure":world.get_structure_blocks(structureRect),"size":structureRect.size,"file_name":name_edit.text}
	Global.save_structure(data)

func _on_name_edit_text_changed(new_text: String) -> void:
	save_btn.disabled = new_text.is_empty()
	selectedBlock.data["file_name"] = new_text

func _on_x_edit_value_changed(value: float) -> void:
	selectedBlock.data["pos"].x = int(value)

func _on_y_edit_value_changed(value: float) -> void:
	selectedBlock.data["pos"].y = int(value)

func _on_width_edit_value_changed(value: float) -> void:
	selectedBlock.data["size"].x = int(value)

func _on_height_edit_value_changed(value: float) -> void:
	selectedBlock.data["size"].y = int(value)
