extends NinePatchRect

@onready var h_slider: HSlider = $HSlider
@onready var inventory: Control = $".."
@onready var chest: Control = $"../../Chest"
@onready var cooking_pot: Control = $"../../CookingPot"

var transferData : Dictionary = {"id":0,"amount":0,"data":{}}
var transferTo : String
var fromLoc : int
var transferFrom : String

func begin_transfer(itemData : Dictionary, to : String, loc : int, from := "inventory") -> void:
	transferData = itemData.duplicate(true)
	transferTo = to
	fromLoc = loc
	transferFrom = from
	$Title.text = "Transfer"
	h_slider.max_value = transferData["amount"]
	h_slider.value = transferData["amount"]
	update_transfer()
	show()

func finished_transfer(itemData : Dictionary) -> void:
	match transferFrom:
		"chest":
			chest.currentChest.data[fromLoc]["amount"] -= h_slider.value
			if chest.currentChest.data[fromLoc]["amount"] <= 0:
				chest.currentChest.data.remove_at(fromLoc)
			if !itemData.is_empty():
				chest.add_to_chest(itemData["id"],itemData["amount"],itemData["data"])
			else:
				chest.update_chest()
		"cooking_pot":
			cooking_pot.currentPot.data["fuel"]["amount"] -= h_slider.value - (0 if itemData.is_empty() else itemData["amount"])
			if cooking_pot.currentPot.data["fuel"]["amount"] <= 0:
				cooking_pot.currentPot.data["fuel"] = {"id":0,"amount":0,"data":{}}
			cooking_pot.update_textures()

func update_transfer() -> void:
	$Amount.text = str(h_slider.value) + "/" + str(transferData["amount"])

func _on_btn_25_pressed() -> void:
	h_slider.value = int(transferData["amount"] * 0.25)
	update_transfer()

func _on_btn_50_pressed() -> void:
	h_slider.value = int(transferData["amount"] * 0.5)
	update_transfer()

func _on_btn_75_pressed() -> void:
	h_slider.value = int(transferData["amount"] * 0.75)
	update_transfer()

func _on_done_btn_pressed() -> void:
	inventory.transfer_items({"id":transferData["id"],"amount":h_slider.value,"data":transferData["data"]},transferTo,fromLoc)
	hide()

func _on_h_slider_value_changed(_value: float) -> void:
	update_transfer()
