extends Control

const O2_SAFE_TEXTURE = preload("res://textures/GUI/main/hotbar/O2-safe.png")
const O2_DANGER_TEXTURE = preload("res://textures/GUI/main/hotbar/O2-danger.png")

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
		$"../HBoxContainer/O2".texture = O2_SAFE_TEXTURE
		$"../HBoxContainer/Warning/AnimationPlayer".play("RESET")
	else:
		$"../HBoxContainer/O2".texture = O2_DANGER_TEXTURE
		if !player.inSuit:
			$"../HBoxContainer/Warning/AnimationPlayer".play("blink")
		else:
			$"../HBoxContainer/Warning/AnimationPlayer".play("RESET")
