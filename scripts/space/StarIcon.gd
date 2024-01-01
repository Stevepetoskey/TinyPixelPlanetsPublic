extends TextureButton

onready var galaxy = get_node("../../..")

var systemSeed = 0
var systemId = ""

func _pressed():
	galaxy.system_pressed(self)
