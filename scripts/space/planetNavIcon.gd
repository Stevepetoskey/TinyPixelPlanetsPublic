extends HBoxContainer

@onready var main = get_node("../../../..")

var discoverd : bool = false
var id : = 0

func _on_btn_pressed() -> void:
	main.nav_icon_pressed(id)
