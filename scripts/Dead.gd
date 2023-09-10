extends Control

onready var inventory = get_node("../Inventory")
onready var cursor = get_node("../../Cursor")
onready var world = get_node("../../World")
onready var player = get_node("../../Player")

func popup():
	inventory.inventoryToggle(false)
	get_node("../Pause").toggle_pause(false)
	cursor.pause = true
	inventory.invPause = true
	show()


func _on_Respawn_pressed():
	cursor.pause = false
	inventory.invPause = false
	player.health = player.maxHealth
	player.oxygen = player.maxOxygen
	Global.save(world.get_world_data(false))
	yield(get_tree(),"idle_frame")
	StarSystem.land(Global.starterPlanetId)

func _on_Quit_pressed():
	get_node("../Pause")._on_Quit_pressed()
