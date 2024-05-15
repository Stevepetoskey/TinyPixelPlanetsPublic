extends Panel

var currentSign = null

@onready var text_edit: TextEdit = $TextEdit
@onready var mode_btn: Button = $HBoxContainer/ModeBtn
@onready var radius_int: SpinBox = $HBoxContainer/RadiusInt
@onready var radius_lbl: Label = $HBoxContainer/RadiusLbl

func _ready() -> void:
	for color in $HBoxContainer/GridContainer.get_children():
		color.connect("pressed", Callable(self, "color_pressed").bind(color.modulate))

func pop_up(sign):
	currentSign = sign
	Global.pause = true
	text_edit.text = currentSign.data["text"]
	text_edit.add_theme_color_override("font_color",currentSign.data["text_color"])
	mode_btn.text = currentSign.data["mode"]
	if currentSign.data["mode"] == "Area":
		radius_int.value = currentSign.data["radius"]
		radius_int.show()
		radius_lbl.show()
	else:
		radius_int.hide()
		radius_lbl.hide()
	show()

func color_pressed(color : Color):
	currentSign.data["text_color"] = color
	text_edit.add_theme_color_override("font_color",color)

func _on_text_edit_text_changed() -> void:
	currentSign.data["text"] = text_edit.text

func _on_mode_btn_pressed() -> void:
	currentSign.data["mode"] = "Click" if currentSign.data["mode"] == "Area" else "Area"
	mode_btn.text = currentSign.data["mode"]
	if currentSign.data["mode"] == "Area":
		currentSign.data["radius"] = 2
		radius_int.value = 2
		radius_int.show()
		radius_lbl.show()
	else:
		radius_int.hide()
		radius_lbl.hide()

func _on_radius_int_value_changed(value: float) -> void:
	currentSign.data["radius"] = value
	currentSign.mainCol.shape.size = Vector2(value*16,value*16)

func _on_close_btn_pressed() -> void:
	Global.pause = false
	hide()

func _on_lock_btn_pressed() -> void:
	currentSign.data["locked"] = true
	currentSign.get_node("Sprite2D").texture = load("res://textures/blocks/sign.png")
	Global.pause = false
	hide()
