extends TextureButton

const COMPLETED = preload("res://textures/GUI/GlobalGUI/Ach_completed.png")
const UNLOCKED = preload("res://textures/GUI/GlobalGUI/Ach_shown.png")
const LOCKED = preload("res://textures/GUI/GlobalGUI/Ach_unkown.png")

export var id : String

onready var main = $"../../../.."

func _ready():
	main.connect("update_achievements",self,"update_ach")

func update_ach(list):
	$Icon.show()
	$Icon.texture = main.achievements[id]["icon"]
	if list.has(id):
		texture_normal = COMPLETED
	elif list.has(main.achievements[id]["requires"]):
		texture_normal = UNLOCKED
	else:
		texture_normal = LOCKED
		$Icon.hide()

func _pressed():
	main.ach_pressed(id)
