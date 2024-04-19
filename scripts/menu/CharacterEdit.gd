extends TextureRect

@onready var main = get_node("../..")

func _on_left_pressed():
	main.left(name)


func _on_right_pressed():
	main.right(name)
