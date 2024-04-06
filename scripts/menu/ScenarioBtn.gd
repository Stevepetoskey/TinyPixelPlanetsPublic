extends TextureButton

export var scenarioId : String

onready var main = $"../../.."

func _ready():
	$TextureRect.texture = main.scenarios[scenarioId]["icon"]
	$Label.text = main.scenarios[scenarioId]["title"]

func _pressed():
	main.scenario_btn_pressed(scenarioId)
