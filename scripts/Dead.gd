extends Control

onready var inventory = get_node("../Inventory")
onready var cursor = get_node("../../Cursor")
onready var world = get_node("../../World")
onready var player = get_node("../../Player")

func popup():
	if Global.gamerules["can_respawn"]:
		$VBoxContainer/Respawn.show()
	else:
		$VBoxContainer/Respawn.hide()
	GlobalGui.close_ach()
	inventory.inventoryToggle(false)
	get_node("../Pause").toggle_pause(false)
	Global.pause = true
	show()


func _on_Respawn_pressed():
	Global.pause = false
	player.health = player.maxHealth
	player.oxygen = player.maxOxygen
	Global.save("planet",world.get_world_data())
	yield(get_tree(),"idle_frame")
	StarSystem.land(Global.starterPlanetId)

func _on_Quit_pressed():
	get_node("../Pause")._on_Quit_pressed()
