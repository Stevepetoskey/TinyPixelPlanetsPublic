extends Button

const UNKOWN = preload("res://textures/GUI/GlobalGUI/ach_unkown_overlay.png")
const LOCKED = preload("res://textures/GUI/GlobalGUI/ach_locked.png")

@export var id : String

@onready var main = $"../../../.."
@onready var overlay: TextureRect = $Overlay

func _ready():
	main.connect("update_achievements", Callable(self, "update_ach"))

func update_ach(list):
	$Icon.show()
	overlay.show()
	theme = load("res://themes/menu.tres")
	$Icon.texture = main.achievements[id]["icon"]
	if list.has(id):
		theme = load("res://themes/menu_alt.tres")
		overlay.hide()
	elif list.has(main.achievements[id]["requires"]):
		overlay.texture = LOCKED
	else:
		overlay.texture = UNKOWN
		$Icon.hide()

func _pressed():
	main.ach_pressed(id)
