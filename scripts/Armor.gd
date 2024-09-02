extends TextureRect

var armor = {"Helmet":{},"Hat":{},"Chestplate":{},"Shirt":{},"Leggings":{},"Pants":{},"Boots":{},"Shoes":{}}

@onready var inventory = get_node("..")
@onready var world = get_node("../../../World")

signal updated_armor

# Called when the node enters the scene tree for the first time.
func _ready():
	for armorBtn in $GridContainer.get_children():
		armorBtn.connect("armor_btn_pressed", Callable(self, "armor_btn_pressed"))

func armor_btn_pressed(icon : Object):
	if inventory.holding:
		var itemData = world.get_item_data(inventory.inventory[inventory.holdingRef]["id"])
		if itemData.has("type") and itemData["type"] == "armor":
			var armorType = itemData["armor_data"]["armor_type"]
			if icon.type == armorType:
				var replace = null
				if !armor[icon.name].is_empty():
					replace = armor[icon.name]
				armor[icon.name] = inventory.inventory[inventory.holdingRef]
				if replace != null:
					inventory.inventory[inventory.holdingRef] = replace
				else:
					inventory.remove_loc_from_inventory(inventory.holdingRef)
				emit_signal("updated_armor",armor)
			inventory.update_inventory()
	elif !armor[icon.name].is_empty():
		inventory.inventory.append(armor[icon.name])
		armor[icon.name] = {}
		inventory.update_inventory()
		emit_signal("updated_armor",armor)

func mouse_in_bn(armorType : String):
	if !armor[armorType].is_empty():
		var itemData = world.get_item_data(armor[armorType]["id"])
		if itemData.has("name"):
			var text = itemData["name"]
			if itemData.has("desc"):
				text += "\n" + itemData["desc"]
			$"../../ItemData".show()
			$"../../ItemData".text = text

func mouse_in_btn(armorType : String):
	if !armor[armorType].is_empty():
		$"../../ItemData".display(armor[armorType])

func mouse_out_btn(_armorType : String):
	$"../../ItemData".hide()
