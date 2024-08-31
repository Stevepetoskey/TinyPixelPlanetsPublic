extends Panel

@onready var world: Node2D = $"../../World"

func _on_yes_btn_pressed() -> void:
	Global.playerData["original_system"] = Global.currentSystemId
	Global.playerData["original_planet"] = Global.currentPlanet
	GlobalGui.complete_achievement("The endgame")
	Global.save("planet", world.get_world_data())
	Global.teleport_to_planet("2340163271682",1)

func _on_no_btn_pressed() -> void:
	hide()
