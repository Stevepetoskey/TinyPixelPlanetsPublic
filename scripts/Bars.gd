extends Control

@onready var player: Player = $"../../../Player"
@onready var health_progress: TextureProgressBar = $Health/Progress
@onready var stamina_progress: TextureProgressBar = $Stamina/Progress
@onready var oxygen: TextureRect = $"../../Oxygen"
@onready var oxygen_progress: TextureProgressBar = $"../../Oxygen/Progress"

func _on_player_stat_changed() -> void:
	health_progress.max_value = player.maxHealth
	health_progress.value = player.health
	if player.oxygen < player.maxOxygen or player.suitOxygen < player.suitOxygenMax:
		oxygen.show()
		oxygen_progress.max_value = player.maxOxygen + (player.suitOxygenMax if player.armorBuff == "air_tight" else 0)
		oxygen_progress.value = player.oxygen + (player.suitOxygen if player.armorBuff == "air_tight" else 0)
	else:
		oxygen.hide()
