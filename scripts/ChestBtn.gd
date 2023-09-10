extends TextureButton

var loc = 0

onready var main = get_node("../..")

func _pressed() -> void:
	main.chest_btn_clicked(loc,self)
