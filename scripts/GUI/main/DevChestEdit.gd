extends Panel

@onready var group_edit: LineEdit = $VBoxContainer/GroupEdit
@onready var title_lbl: Label = $TitleLbl

var selectedBlock : BaseBlock

func pop_up(block : BaseBlock, type : String):
	title_lbl.text = type
	Global.pause = true
	selectedBlock = block
	group_edit.text = selectedBlock.data["group"]
	show()

func _on_group_edit_text_changed(new_text: String) -> void:
	selectedBlock.data["group"] = new_text

func _on_save_btn_pressed() -> void:
	Global.pause = false
	hide()
