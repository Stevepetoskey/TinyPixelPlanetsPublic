extends Control

const SHOP_BTN = preload("res://assets/GUI/ShopItem.tscn")

var shopData = {
	"lily_mart":{
		"buy":[
			{"id":121,"amount":5,"cost":10},
			{"id":122,"amount":5,"cost":15},
			{"id":123,"amount":5,"cost":20},
			{"id":140,"amount":2,"cost":20},
			{"id":129,"amount":1,"cost":35},
			{"id":130,"amount":1,"cost":75},
			{"id":131,"amount":1,"cost":100},
			{"id":132,"amount":1,"cost":100},
		],
		"sell":[
			{"id":125,"value":2},
			{"id":126,"value":3},
			{"id":127,"value":4},
			{"id":140,"value":8},
			{"id":121,"value":1},
			{"id":122,"value":1},
			{"id":123,"value":2},
		],
		"face":{"happy":preload("res://textures/NPCs/faces/lily_happy.png"),"cheerful":preload("res://textures/NPCs/faces/lily_cheerful.png")},
		"dialogue":{
			"welcome":["Welcome to my shop! I have all the best farming goods in the galaxy."],
			"purchase":["Thank you partner!","Enjoy your purchase!"],
			"sell":["This will go well in my collection.","Thank you partner!"],
			"decline":["Sorry partner, come back when you are a little mmm richer."]
		},
		"name":"Lily Mart"
	},
	"skips_stones":{
		"buy":[
			{"id":52,"amount":1,"cost":15},
			{"id":56,"amount":1,"cost":25},
			{"id":74,"amount":1,"cost":50},
			{"id":100,"amount":5,"cost":25},
			{"id":101,"amount":5,"cost":25},
			{"id":102,"amount":5,"cost":25},
			{"id":103,"amount":5,"cost":25},
			{"id":81,"amount":6,"cost":40},
			{"id":15,"amount":10,"cost":20},
			{"id":3,"amount":10,"cost":18},
			{"id":71,"amount":10,"cost":26},
			{"id":72,"amount":10,"cost":30},
			{"id":75,"amount":10,"cost":30},
		],
		"sell":[
			{"id":3,"value":1},
			{"id":29,"value":5},
			{"id":55,"value":10},
			{"id":73,"value":18},
			{"id":52,"value":7},
			{"id":56,"value":12},
			{"id":74,"value":20},
		],
		"face":{"happy":preload("res://textures/NPCs/faces/skip_happy.png"),"cheerful":preload("res://textures/NPCs/faces/skip_cheerful.png")},
		"dialogue":{
			"welcome":["Welcome traveler to me shop, best stones cheap price"],
			"purchase":["Great choice!","Isn't it wonderful?"],
			"sell":["Many gratitudes","So ssshiny"],
			"decline":["No money, no mineral"]
		},
		"name":"Skip's Stones"
	}
}

var currentShop = ""
var currentTab = "buy"

@onready var dialogue : RichTextLabel = $Dialogue
@onready var face_texture : TextureRect = $Face
@onready var buy_tab = $TabBar/BuyTab
@onready var sell_tab = $TabBar/SellTab
@onready var item_container: GridContainer = $ItemScroll/ItemContainer
@onready var inventory: Control = $"../Inventory"
@onready var title: Label = $Title

func pop_up(shopID : String):
	buy_tab.disabled = true
	sell_tab.disabled = false
	currentShop = shopID
	title.text = shopData[currentShop]["name"]
	currentTab = "buy"
	update_list()
	show()
	play_dialogue("welcome","happy")

func update_list():
	for child in item_container.get_children():
		child.queue_free()
	match currentTab:
		"buy":
			for item in shopData[currentShop]["buy"]:
				var shopBtn = SHOP_BTN.instantiate()
				shopBtn.mode = "buy"
				shopBtn.id = item["id"]
				shopBtn.amount = item["amount"]
				shopBtn.cost = item["cost"]
				shopBtn.loc = shopData[currentShop]["buy"].find(item)
				item_container.add_child(shopBtn)
		"sell":
			for item in shopData[currentShop]["sell"]:
				if inventory.count_id(item["id"]) > 0:
					var shopBtn = SHOP_BTN.instantiate()
					shopBtn.mode = "sell"
					shopBtn.id = item["id"]
					shopBtn.cost = item["value"]
					shopBtn.loc = shopData[currentShop]["sell"].find(item)
					item_container.add_child(shopBtn)

func shop_btn_pressed(loc : int, amount := 0) -> void:
	match currentTab:
		"buy":
			var itemData = shopData[currentShop]["buy"][loc]
			if Global.blues >= itemData["cost"]:
				Global.blues -= itemData["cost"]
				inventory.add_to_inventory(itemData["id"],itemData["amount"])
				play_dialogue("purchase","cheerful")
			else:
				play_dialogue("decline","happy")
		"sell":
			var itemData = shopData[currentShop]["sell"][loc]
			Global.blues += itemData["value"] * amount
			inventory.remove_id_from_inventory(itemData["id"],amount)
			update_list()
			play_dialogue("sell","cheerful")

func play_dialogue(sample : String, face : String) -> void:
	var diaSamp : Array = shopData[currentShop]["dialogue"][sample].duplicate()
	diaSamp.shuffle()
	dialogue.text = ""
	var finalText : String = diaSamp[0]
	face_texture.texture = shopData[currentShop]["face"][face]
	for i in range(finalText.length()):
		dialogue.text += finalText[i]
		await get_tree().create_timer(0.05).timeout
	dialogue.text = finalText

func _on_BuyTab_pressed() -> void:
	$TabBar/SellTab.disabled = false
	$TabBar/BuyTab.disabled = true
	currentTab = "buy"
	update_list()

func _on_SellTab_pressed() -> void:
	$TabBar/SellTab.disabled = true
	$TabBar/BuyTab.disabled = false
	currentTab = "sell"
	update_list()
