extends Control

var currentMusicPlayer : LogicBlock

var discData : Dictionary = {
	238:{"title":"Alpha Andromedae","by":"The_Mad_Duck"},
	239:{"title":"Past","by":"The_Mad_Duck"},
	240:{"title":"Tinkering Machine","by":"HzSmith"},
}

@onready var item_texture: TextureRect = $MusicChipSlot/ItemTexture
@onready var world: Node2D = $"../../World"
@onready var title_lbl: Label = $Data/VBoxContainer/TitleLbl
@onready var by_lbl: Label = $Data/VBoxContainer/ByLbl
@onready var inventory: Control = $"../Inventory"

func pop_up() -> void:
	update_data()
	show()

func update_data() -> void:
	var currentChip : Dictionary = currentMusicPlayer.data["current_track"]
	if discData.has(currentChip["id"]):
		item_texture.texture = world.get_item_texture(currentChip["id"])
		title_lbl.text = discData[currentChip["id"]]["title"]
		by_lbl.text = discData[currentChip["id"]]["by"]
	else:
		item_texture.texture = null
		title_lbl.text = "No music chip"
		by_lbl.text = ""

func _on_music_chip_slot_pressed() -> void:
	var currentChip : Dictionary = currentMusicPlayer.data["current_track"]
	if inventory.holding:
		var holdingItemData : Dictionary = inventory.inventory[inventory.holdingRef]
		if discData.has(holdingItemData["id"]):
			if currentChip["id"] == 0:
				currentMusicPlayer.data["current_track"] = holdingItemData.duplicate(true)
				inventory.remove_loc_from_inventory(inventory.holdingRef)
				currentMusicPlayer.calculate()
				update_data()
			else:
				var toInventory = currentChip.duplicate(true)
				currentMusicPlayer.data["current_track"] = holdingItemData.duplicate(true)
				inventory.inventory[inventory.holdingRef] = toInventory
				currentMusicPlayer.data["is_playing"] = false
				currentMusicPlayer.calculate()
				update_data()
	elif currentChip["id"] != 0:
		inventory.add_to_inventory(currentChip["id"],currentChip["amount"],true,currentChip["data"].duplicate(true))
		currentMusicPlayer.data["current_track"] = GlobalData.emptyItem.duplicate(true)
		currentMusicPlayer.data["is_playing"] = false
		currentMusicPlayer.calculate()
		update_data()

func _on_music_chip_slot_mouse_entered() -> void:
	if currentMusicPlayer != null and currentMusicPlayer.data["current_track"]["id"] != 0:
		$"../ItemData".display(currentMusicPlayer.data["current_track"])

func _on_music_chip_slot_mouse_exited() -> void:
	$"../ItemData".hide()
