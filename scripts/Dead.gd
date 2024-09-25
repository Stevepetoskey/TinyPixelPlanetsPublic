extends Control

@onready var inventory = get_node("../Inventory")
@onready var cursor = get_node("../../Cursor")
@onready var world = get_node("../../World")
@onready var player: CharacterBody2D = $"../../Player"

func popup():
	if Global.gamerules["can_respawn"]:
		$VBoxContainer/Respawn.show()
	else:
		$VBoxContainer/Respawn.hide()
	GlobalGui.close_ach()
	inventory.inventoryToggle(false)
	get_node("../Pause").toggle_pause(false)
	get_tree().paused = true
	show()


func _on_Respawn_pressed():
	get_tree().paused = false
	player.health = player.maxHealth
	player.oxygen = player.maxOxygen
	player.collision_layer = 2
	Global.save("planet",world.get_world_data())
	await get_tree().process_frame
	StarSystem.land(Global.currentPlanet)

func _on_Quit_pressed():
	get_node("../Pause")._on_Quit_pressed()
