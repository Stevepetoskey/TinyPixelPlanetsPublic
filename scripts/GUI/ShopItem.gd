extends TextureRect

var id = 0
var amount = 0
var cost = 0
var mode = "buy"
var loc = 0

@onready var down_btn: TextureButton = $DownBtn
@onready var up_btn: TextureButton = $UpBtn
@onready var amount_lbl: Label = $Amount
@onready var item: TextureRect = $Item
@onready var blues_amount: Label = $Sell/HBoxContainer/Amount
@onready var world: Node2D = $"../../../../../World"
@onready var inventory: Control = $"../../../../Inventory"
@onready var shop: Control = $"../../.."

func _ready() -> void:
	item.texture = world.get_item_texture(id)
	match mode:
		"buy":
			down_btn.hide()
			up_btn.hide()
			blues_amount.text = "*" + str(cost)
		"sell":
			blues_amount.text = "*0"
	amount_lbl.text = "x" + str(amount)

func update_stuff():
	amount_lbl.text = "x" + str(amount)
	blues_amount.text = "*" + str(cost*amount)

func _on_UpBtn_pressed() -> void:
	if inventory.count_id(id) > amount:
		amount += 1
		update_stuff()

func _on_DownBtn_pressed() -> void:
	if amount > 0:
		amount -= 1
		update_stuff()

func _on_Sell_pressed() -> void:
	shop.shop_btn_pressed(loc,amount)
