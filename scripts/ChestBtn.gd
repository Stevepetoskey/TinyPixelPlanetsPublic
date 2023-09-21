extends TextureButton

var loc = 0

onready var main = get_node("../..")

func _pressed() -> void:
	main.chest_btn_clicked(loc,self)


func _on_ChestBtn_mouse_entered():
	main.mouse_in_btn(loc)

func _on_ChestBtn_mouse_exited():
	main.mouse_out_btn(loc)
