extends TextureButton

export var id = 0

onready var main = get_node("../..")

func _ready():
	$Label.text = "SAVE " + str(id+1)

func _pressed():
	main.save_clicked(self)

func _on_delete_pressed():
	main.delete_file(self)
