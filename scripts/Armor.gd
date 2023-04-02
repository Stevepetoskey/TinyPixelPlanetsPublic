extends TextureRect

var armor = {"Helmet":{},"Hat":{},"Chestplate":{},"Shirt":{},"Leggings":{},"Pants":{},"Boots":{},"Shoes":{}}

onready var inventory = get_node("..")
onready var world = get_node("../../../World")

signal updated_armor

# Called when the node enters the scene tree for the first time.
func _ready():
	for armorBtn in $GridContainer.get_children():
		armorBtn.connect("armor_btn_pressed",self,"armor_btn_pressed")
	emit_signal("updated_armor",armor)

func armor_btn_pressed(icon : Object):
	if inventory.holding:
		var itemData = world.get_item_data(inventory.inventory[inventory.holdingRef]["id"])
		if itemData.has("type") and itemData["type"] == "armor":
			var armorType = itemData["armor_data"]["armor_type"]
			if icon.type == armorType:
				var replace = null
				if !armor[icon.name].empty():
					replace = armor[icon.name]
				armor[icon.name] = inventory.inventory[inventory.holdingRef]
				if replace != null:
					inventory.inventory[inventory.holdingRef] = replace
				else:
					inventory.inventory.remove(inventory.holdingRef)
				emit_signal("updated_armor",armor)
			inventory.update_inventory()
	elif !armor[icon.name].empty():
		inventory.inventory.append(armor[icon.name])
		armor[icon.name] = {}
		inventory.update_inventory()
		emit_signal("updated_armor",armor)
