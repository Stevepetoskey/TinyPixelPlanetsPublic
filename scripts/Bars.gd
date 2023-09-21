extends Control

onready var player = get_node("../../../Player")

func _process(delta):
	$Health.max_value = player.maxHealth
	$Health.value = player.health
	$Oxygen.max_value = player.maxOxygen
	$Oxygen.value = player.oxygen
	if player.inSuit:
		$"../../Oxygen".show()
		$"../../Oxygen/suitOxygen".value = player.suitOxygen
		$"../../Oxygen/suitOxygen".max_value = player.suitOxygenMax
	else:
		$"../../Oxygen".hide()
	if player.canBreath:
		$"../HBoxContainer/O2".texture = load("res://textures/GUI/main/O2-safe.png")
		$"../HBoxContainer/Warning/AnimationPlayer".play("RESET")
	else:
		$"../HBoxContainer/O2".texture = load("res://textures/GUI/main/O2-danger.png")
		if !player.inSuit:
			$"../HBoxContainer/Warning/AnimationPlayer".play("blink")
		else:
			$"../HBoxContainer/Warning/AnimationPlayer".play("RESET")
