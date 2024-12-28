extends CanvasLayer

var achievements : Dictionary= {
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

var tutorials : Dictionary = {
	"gameplay":{
		"display_name":"Gameplay",
		"sub_tutorials":{
			"tutorial_popup":{
				"display_name":"Tutorial Popup",
				"icon":"none",
				"content":"Welcome to Tiny Pixel Planets! These tutorial popups will help you progress through the game. You can find all tutorials by pressing esc."
			},
			"movement":{
				"display_name":"Movement",
				"icon":"none",
				"content":"Move left and right with the A/D keys or the arrow keys. Jump by pressing the space key. Sprint by holding the shift key."
			},
			"hotbar":{
				"display_name":"The Hotbar",
				"icon":"none",
				"content":"You have two hotbar slots. The left hotbar slot can be used by left clicking. The right hotbar slot is used by right clicking. You can put any item/block in the two hotbar slots."
			},
			"gather_resources":{
				"display_name":"Gathering Resources",
				"icon":"none",
				"content":"First, mine a tree. This can be done by using the wooden pickaxe in your left hotbar slot. Hold the left mouse button on the bottom most block of the tree to mine it."
			},
			"gather_resources2":{
				"display_name":"Gathering Resources",
				"icon":"none",
				"content":"This is how to gather all resources, not just trees. Gathering resources is important for crafting better items."
			},
			"inventory":{
				"display_name":"The Inventory",
				"icon":"none",
				"content":"Open your inventory by pressing E."
			},
			"inventory2":{
				"display_name":"The Inventory",
				"icon":"none",
				"content":"Here you can click on items and move them around by clicking on another item."
			},
			"inventory3":{
				"display_name":"The Inventory",
				"icon":"none",
				"content":"Press J or K over an item to add it to your secondary hotbar which is the colored elements with J and K on them. You can then press J or K to use the item. Only certain items can be put in the secondary hotbar, such as tools or weapons."
			},
			"inventory4":{
				"display_name":"The Inventory",
				"icon":"none",
				"content":"The inventory also is where you change your armor/clothes. Click on a piece of armor and then a armor slot to wear it. Click on the armor slot again to take it off."
			},
			"crafting":{
				"display_name":"Crafting",
				"icon":"none",
				"content":"In the inventory GUI you can see the crafting panel to the right. You can craft an item by clicking on the item, and pressing the craft button if you have the required resources."
			},
		}
	},
	"space":{
		"display_name":"Space",
		"sub_tutorials":{
			"star_system":{
				"display_name":"Star system navigation",
				"icon":"none",
				"content":"The white arrow will point you to the nearest planet/ the star. Click the arrow on the bottom left and then click the system button to see all the planets in the system."
			},
			"star_system2":{
				"display_name":"Star system navigation",
				"icon":"none",
				"content":"As you explore more planets they will appear here replacing the question marks. Click on any of the icons to be able to locate that planet. Move your ship around with WASD or the arrow keys"
			},
			"star_system3":{
				"display_name":"Star system navigation",
				"icon":"none",
				"content":"Click on any planet to see the planet’s info, change the name, or bookmark the planet."
			},
			"bookmarks":{
				"display_name":"Bookmarks",
				"icon":"none",
				"content":"When you bookmark a planet you can choose the bookmark name, color, and icon. Once bookmarked you can then return to this exact planet no matter where you are in the galaxy by using the bookmark button in galaxy navigation."
			},
			"galaxy":{
				"display_name":"Galaxy navigation",
				"icon":"none",
				"content":"Here you can travel between star systems. Click on any of the stars and a pop up will show you what planet types can be found in the star system. Click again to travel to that star system. Press the bookmark button to browse your bookmarks."
			},
			"versitalis":{
				"display_name":"Versitalis",
				"icon":"none",
				"content":"Versitalis is the capital of the Blue Jays. Here you can do all your shopping/selling."
			},
		}
	},
	"blocks":{
		"display_name":"Blocks",
		"sub_tutorials":{
			"crafting_table":{
				"display_name":"Crafting table",
				"icon":"res://textures/blocks/crafting_table.png",
				"content":"Used for crafting more items then you can with just the inventory crafting. Click to use."
			},
			"oven":{
				"display_name":"Oven",
				"icon":"res://textures/blocks/oven.png",
				"content":"Used for smelting ores and blocks. Click to use."
			},
			"smithing_table":{
				"display_name":"Smithing table",
				"icon":"res://textures/blocks/smithing_table.png",
				"content":"Used for crafting armor, weapons, and tools. Click to use."
			},
			"platforms":{
				"display_name":"Platforms",
				"icon":"res://textures/blocks/platform_full.png",
				"content":"Can jump through but cannot fall through. Press ‘S’ or the down key to drop off the platform."
			},
			"chests":{
				"display_name":"Chests",
				"icon":"res://textures/blocks/chest.png",
				"content":"Click to open the chest, and then click on items in your inventory to transfer over to the chest. Click to use."
			},
			"seeds":{
				"display_name":"Seeds",
				"icon":"res://textures/items/wheat_seeds.png",
				"content":"Can only be placed on farmland. Used to grow crops."
			},
			"signs":{
				"display_name":"Signs",
				"icon":"res://textures/blocks/sign_empty.png",
				"content":"Click to edit sign text. Used to display text."
			},
			"lever":{
				"display_name":"Lever",
				"icon":"res://textures/blocks/lever_off.png",
				"content":"Click to toggle on and off."
			},
			"display_block":{
				"display_name":"Display block",
				"icon":"res://textures/blocks/display_block_off.png",
				"content":"Lights up when receiving an input, otherwise it is off."
			},
			"logic_block":{
				"display_name":"Logic block",
				"icon":"res://textures/blocks/logic_block_and.png",
				"content":"Click to change logic mode. Compares all inputs using the logic mode and outputs the result."
			},
			"flip_block":{
				"display_name":"Flip block",
				"icon":"res://textures/blocks/flip_block_off.png",
				"content":"Toggles when receiving an input."
			},
			"doors":{
				"display_name":"Doors",
				"icon":"res://textures/items/door_icon.png",
				"content":"Place two blocks above the ground. Click to open/close."
			},
			"button":{
				"display_name":"Button",
				"icon":"res://textures/blocks/button_off.png",
				"content":"Outputs a signal as long as it is clicked."
			},
			"upgrade_table":{
				"display_name":"Upgrade table",
				"icon":"res://textures/blocks/upgrade_table.png",
				"content":"Click to open GUI. Upgrades weapons, tools, and armor using upgrade chips. Find upgrade chips in scorched and frigid dungeons."
			},
			"music_player":{
				"display_name":"Music player",
				"icon":"res://textures/blocks/music_player.png",
				"content":"Plays music chips when receiving an input. Click to use."
			},
			"timer_block":{
				"display_name":"Timer block",
				"icon":"res://textures/blocks/timer_block.png",
				"content":"Outputs a signal every set time when receiving an input. Click to change time."
			},
			"endgame_locator":{
				"display_name":"Endgame locator",
				"icon":"res://textures/blocks/endgame_locator.png",
				"content":"The last step. Used to teleport you to the endgame planet. But you must power it up with magma balls and frigid shards by clicking on it."
			},
			"wool_work_table":{
				"display_name":"Wool work table",
				"icon":"res://textures/blocks/wool_work_table.png",
				"content":"Used to craft wool related items and armor. Click to use."
			},
		}
	},
	"items":{
		"display_name":"Items",
		"sub_tutorials":{
			"buckets":{
				"display_name":"Buckets",
				"icon":"res://textures/items/silver_bucket_level_4.png",
				"content":"Click on water to fill the bucket if empty. Click on an empty space with water in the bucket to place the remaining water in the bucket. Buckets can hold up to 4 layers of water."
			},
			"hoes":{
				"display_name":"Hoes",
				"icon":"res://textures/items/silver_hoe.png",
				"content":"Used to till soil into farmland. Use a hoe on a regular grass or dirt block to turn it into farmland. Farmland requires it to be wet from either the rain or nearby water to grow crops."
			},
			"watering_cans":{
				"display_name":"Watering cans",
				"icon":"res://textures/items/filled_silver_watering_can.png",
				"content":"Used to water farmland and make it wet. Can be used 8 times if completely filled with a block of water."
			},
			"wires":{
				"display_name":"Wires",
				"icon":"res://textures/items/red_wires.png",
				"content":"Put in the hotbar slots to see wires and inputs of wire blocks. Click on outputs with the wire and then click on an input to complete the wire."
			},
			"magma_ball":{
				"display_name":"Magma ball",
				"icon":"res://textures/items/magma_ball.png",
				"content":"Used to power the endgame locator."
			},
			"coolant_shard":{
				"display_name":"Coolant shard",
				"icon":"res://textures/items/coolant_shard.png",
				"content":"Used to craft fire armor and to power the endgame locator."
			},
			"upgrade_module":{
				"display_name":"Upgrade module",
				"icon":"res://textures/items/upgrade_module.png",
				"content":"Used to upgrade your tool, armor, or weapon in an upgrade table."
			},
			"music_chips":{
				"display_name":"Music chips",
				"icon":"res://textures/items/music_chip_alpha_andromedae.png",
				"content":"Can be played in a music player."
			},
		}
	}
}

var completedTutorials : Array = []
var completedAchievements : Array = []

var backedUpRequest : Array = []

signal update_achievements
signal autosave
signal tutorial_closed

@onready var achievementPnl = $Achievement
@onready var auto_save_timer: Timer = $AutoSaveTimer

func _process(delta):
	if GlobalAudio.mode != "menu":
		if Input.is_action_just_pressed("ach") and (!get_tree().paused or $AchievementMenu.visible):
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

func display_tutorial(groupId : String,tutorialId : String, dir : String = "left", showOkBtn : bool = false, showTime : float = -1.0) -> void:
	if Global.gamerules["tutorial"]:
		$TutorialPopup.append_tutorial(groupId, tutorialId,showOkBtn,showTime,dir)

func end_current_tutorial() -> void:
	print("ending tutorial")
	$TutorialPopup.close(true,true)

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
	$TutorialPopup.close()
	auto_save_timer.stop()

func _on_auto_save_timer_timeout() -> void:
	$AutosaveIcon/AnimationPlayer.play("pulse")
	await get_tree().create_timer(2.0).timeout
	autosave.emit()
