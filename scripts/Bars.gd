extends Control

@onready var player = get_node("../../../Player")

func _process(delta):
	$Health.max_value = player.maxHealth
	$Health.value = player.health
	$Oxygen.max_value = player.maxOxygen
	$Oxygen.value = player.oxygen
	if player.armorBuff == "air_tight":
		$"../../Oxygen".show()
		$"../../Oxygen/suitOxygen".value = player.suitOxygen
		$"../../Oxygen/suitOxygen".max_value = player.suitOxygenMax
	else:
		$"../../Oxygen".hide()
