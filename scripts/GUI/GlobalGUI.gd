extends CanvasLayer

var achievements = {
	"One small step":{"desc":"Mine your first block using your pickaxe","requires":"none","icon":preload("res://textures/items/armor/space_helmet.png")},
	"An upgrade":{"desc":"Craft a stone pickaxe","requires":"One small step","icon":preload("res://textures/items/stone_pick.png")},
	"The mechanic":{"desc":"Fly your ship into space","requires":"One small step","icon":preload("res://textures/ships/blue_ship_icon.png")},
	"Ready for battle":{"desc":"Craft a weapon","requires":"One small step","icon":preload("res://textures/items/barbed_club.png")},
	"Winter ready":{"desc":"Suit up in full coat armor to survive on frigid planets","requires":"Interplanetary","icon":preload("res://textures/items/armor/coat.png")},
	"Into ice":{"desc":"Collect a coolant shard from a frigid spike","requires":"Winter ready","icon":preload("res://textures/items/coolant_shard.png")},
	"Scorched ready":{"desc":"Suit up in full fire armor to survive on scorched planets","requires":"Into ice","icon":preload("res://textures/items/armor/fire_chestplate.png")},
	"Into lava":{"desc":"Collect a magma ball from a scorched guard","requires":"Scorched ready","icon":preload("res://textures/items/magma_ball.png")},
	"Location needed":{"desc":"Craft a endgame locator","requires":"Into lava","icon":preload("res://textures/blocks/endgame_locator.png")},
	"The endgame":{"desc":"Use a locator to teleport to the endgame planet","requires":"Location needed","icon":preload("res://textures/enemies/mini_transporter/trinanium_charge1.png")},
	"The end":{"desc":"Defeat the rogue mini transporter","requires":"The endgame","icon":preload("res://textures/blocks/trinanium_crystal.png")},
	"Top of the line":{"desc":"Craft a rhodonite pickaxe","requires":"An upgrade","icon":preload("res://textures/items/rhodonite_pick.png")},
	"Exotic wear":{"desc":"Wear a full set of rhodonite armor","requires":"Top of the line","icon":preload("res://textures/items/rhodonite.png")},
	"Interplanetary":{"desc":"Travel between two planets in the same star system","requires":"The mechanic","icon":preload("res://textures/planets/terra.png")},
	"Interstellar":{"desc":"Travel between two stars","requires":"Interplanetary","icon":preload("res://textures/GUI/space/star_icon_K-type.png")},
	"Explorer 1":{"desc":"Visit 3 different types of planets","requires":"Interplanetary","icon":preload("res://textures/GUI/main/all_planets_icon.png")},
	"Explorer 2":{"desc":"Visit 6 different types of planets","requires":"Explorer 1","icon":preload("res://textures/GUI/main/all_planets_icon.png")},
	"Explorer 3":{"desc":"Visit all types of planets","requires":"Explorer 2","icon":preload("res://textures/GUI/main/all_planets_icon.png")},
	"Exterminator 1":{"desc":"Kill a enemy","requires":"Ready for battle","icon":preload("res://textures/GUI/main/broken_heart_icon.png")},
	"Exterminator 2":{"desc":"Kill 10 enemies","requires":"Exterminator 1","icon":preload("res://textures/GUI/main/broken_heart_icon.png")},
	"Exterminator 3":{"desc":"Kill 50 enemies","requires":"Exterminator 2","icon":preload("res://textures/GUI/main/broken_heart_icon.png")},
	"Destroyer of worlds":{"desc":"Kill 100 enemies","requires":"Exterminator 3","icon":preload("res://textures/GUI/main/skull_icon.png")},
	"Economist 1":{"desc":"Reach 1,000 blues","requires":"One small step","icon":preload("res://textures/GUI/main/Blues.png")},
	"Economist 2":{"desc":"Reach 5,000 blues","requires":"Economist 1","icon":preload("res://textures/GUI/main/Blues.png")},
	"Economist 3":{"desc":"Reach 10,000 blues","requires":"Economist 3","icon":preload("res://textures/GUI/main/Blues.png")},
}

var completedAchievements = []

var backedUpRequest = []

signal update_achievements
signal autosave

@onready var achievementPnl = $Achievement
@onready var auto_save_timer: Timer = $AutoSaveTimer

func _process(delta):
	if GlobalAudio.mode != "menu":
		if Input.is_action_just_pressed("ach") and (!Global.pause or $AchievementMenu.visible):
			if !$AchievementMenu.visible:
				pop_up_ach()
			else:
				close_ach()
		if !backedUpRequest.is_empty() and !$Achievement/AnimationPlayer.is_playing():
			print("play: ",backedUpRequest[0])
			$Achievement/Icon.texture = achievements[backedUpRequest[0]]["icon"]
			$Achievement/Text.text = backedUpRequest[0]
			$Achievement/AnimationPlayer.play("pop_up")
			backedUpRequest.remove_at(0)

func _ready():
	emit_signal("update_achievements",completedAchievements)
	Global.entered_save.connect(entered_save)
	Global.left_save.connect(left_save)

func complete_achievement(achievement):
	if !completedAchievements.has(achievement) and !Global.inTutorial:
		completedAchievements.append(achievement)
		emit_signal("update_achievements",completedAchievements)
		backedUpRequest.append(achievement)

func pop_up_ach():
	$AchievementMenu/Desc.hide()
	$AchievementMenu.show()
	emit_signal("update_achievements",completedAchievements)

func close_ach():
	$AchievementMenu/Desc.hide()
	$AchievementMenu.hide()

func _on_BackBtn_pressed():
	if !$AchievementMenu/Desc.visible:
		$AchievementMenu.hide()
	else:
		$AchievementMenu/Desc.hide()

func ach_pressed(id):
	var requiredId = achievements[id]["requires"]
	if completedAchievements.has(id) or completedAchievements.has(requiredId):
		$AchievementMenu/Desc/Title.text = id
		$AchievementMenu/Desc/Desc.text = achievements[id]["desc"]
	else:
		$AchievementMenu/Desc/Title.text = "???"
		if requiredId != "none" and completedAchievements.has(achievements[requiredId]["requires"]):
			$AchievementMenu/Desc/Desc.text = "Requires " + requiredId
		else:
			$AchievementMenu/Desc/Desc.text = "Requires ???"
	$AchievementMenu/Desc.show()

func entered_save() -> void:
	print("saving time at: ",GlobalData.autoSaveTimes[Global.settings["autosave_interval"]])
	if Global.settings["autosave_interval"] != 0:
		print("Started save timer")
		auto_save_timer.start(GlobalData.autoSaveTimes[Global.settings["autosave_interval"]])

func left_save() -> void:
	print("stop autosave")
	auto_save_timer.stop()

func _on_auto_save_timer_timeout() -> void:
	$AutosaveIcon/AnimationPlayer.play("pulse")
	await get_tree().create_timer(2.0).timeout
	autosave.emit()
