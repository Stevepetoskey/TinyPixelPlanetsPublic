extends TextureButton

export var id = 0

onready var main = get_node("../..")

func _pressed():
	main.save_clicked(self)

func _on_delete_pressed():
	main.delete_file(self)
