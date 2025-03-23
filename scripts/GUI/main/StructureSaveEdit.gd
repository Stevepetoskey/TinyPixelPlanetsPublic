extends Panel

@onready var x_edit: SpinBox = $VBoxContainer/Position/XEdit
@onready var y_edit: SpinBox = $VBoxContainer/Position/YEdit
@onready var width_edit: SpinBox = $VBoxContainer/Size/WidthEdit
@onready var height_edit: SpinBox = $VBoxContainer/Size/HeightEdit
@onready var name_edit: LineEdit = $VBoxContainer/Name/NameEdit
@onready var save_btn: Button = $SaveBtn
@onready var world: Node2D = $"../../World"
@onready var load_raw_btn: CheckButton = $VBoxContainer/LoadRawBtn

var selectedBlock : BaseBlock

func pop_up(block : BaseBlock):
	get_tree().paused = true
	selectedBlock = block
	var data = selectedBlock.data
	save_btn.disabled = data["file_name"].is_empty()
	x_edit.value = data["pos"].x
	y_edit.value = data["pos"].y
	width_edit.value = data["size"].x
	height_edit.value = data["size"].y
	name_edit.text = data["file_name"]
	load_raw_btn.button_pressed = data["load_raw"]
	show()

func _on_back_btn_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_save_btn_pressed() -> void:
	var structureRect : Rect2 = Rect2(Vector2(int(x_edit.value) + selectedBlock.pos.x,int(y_edit.value) + selectedBlock.pos.y),Vector2(int(width_edit.value),int(height_edit.value)))
	var data = {"structure":world.get_structure_blocks(structureRect),"size":structureRect.size,"file_name":name_edit.text}
	Global.save_structure(data)
	_on_back_btn_pressed()

func _on_name_edit_text_changed(new_text: String) -> void:
	save_btn.disabled = new_text.is_empty()
	selectedBlock.data["file_name"] = new_text

func _on_x_edit_value_changed(value: float) -> void:
	selectedBlock.data["pos"].x = int(value)
	selectedBlock.queue_redraw()

func _on_y_edit_value_changed(value: float) -> void:
	selectedBlock.data["pos"].y = int(value)
	selectedBlock.queue_redraw()

func _on_width_edit_value_changed(value: float) -> void:
	selectedBlock.data["size"].x = int(value)
	selectedBlock.queue_redraw()

func _on_height_edit_value_changed(value: float) -> void:
	selectedBlock.data["size"].y = int(value)
	selectedBlock.queue_redraw()

func _on_load_btn_pressed() -> void:
	var structure : Dictionary = Global.load_structure(name_edit.text + ".dat")
	if !structure.is_empty():
		var offset : Vector2 = selectedBlock.pos + Vector2(int(x_edit.value),int(y_edit.value))
		if selectedBlock.data["load_raw"]:
			for block : Dictionary in structure["structure"]["blocks"]:
				world.set_block(block["position"] + offset,block["layer"],block["id"],false,block["data"])
		else:
			for block : Dictionary in structure["structure"]["blocks"]:
				world.generate_block_from_structure(block,block["position"] + offset)
		_on_back_btn_pressed()
	else:
		printerr("Structure ",name_edit.text + ".dat", " does not exist!")

func _on_load_raw_btn_toggled(toggled_on: bool) -> void:
	selectedBlock.data["load_raw"] = toggled_on
