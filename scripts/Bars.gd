extends Control

onready var player = get_node("../../../Player")

func _process(delta):
	$Health.max_value = player.maxHealth
	$Health.value = player.health
	$Oxygen.max_value = player.maxOxygen
	$Oxygen.value = player.oxygen
