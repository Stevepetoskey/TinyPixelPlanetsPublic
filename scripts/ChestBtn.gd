extends TextureButton

var loc = 0

onready var chest_gui = $"../../.."

func _pressed() -> void:
	chest_gui.chest_btn_clicked(loc,self)


func _on_ChestBtn_mouse_entered():
	chest_gui.mouse_in_btn(loc)

func _on_ChestBtn_mouse_exited():
	chest_gui.mouse_out_btn(loc)
