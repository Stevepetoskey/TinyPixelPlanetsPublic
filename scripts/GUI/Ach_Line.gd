extends TextureRect

const COMPLETED = preload("res://textures/GUI/GlobalGUI/Ach_line_completed.png")
const UNLOCKED = preload("res://textures/GUI/GlobalGUI/Ach_line_shown.png")
const LOCKED = preload("res://textures/GUI/GlobalGUI/Ach_line_unkown.png")

@export var from : String
@export var to : String

@onready var main = $"../../../../.."

func _ready():
	main.connect("update_achievements", Callable(self, "update_ach"))

func update_ach(list):
	if list.has(from):
		if list.has(to):
			texture = COMPLETED
		else:
			texture = UNLOCKED
	else:
		texture = LOCKED
