extends Control

const CRAFT_BTN = preload("res://assets/CraftBtn.tscn")

onready var inventory = get_node("../Inventory")
onready var ITEM_PER_PAGE = inventory.ITEM_PER_PAGE

var recipes = {
	"inventory": [
		{"recipe":[{"id":10,"amount":1}],"result":{"id":13,"amount":4}}, #Planks
		{"recipe":[{"id":13,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench
		{"recipe":[{"id":78,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench (With exotic wood)
		{"recipe":[{"id":77,"amount":1}],"result":{"id":78,"amount":4}}, #Exotic planks
		{"recipe":[{"id":13,"amount":1}],"result":{"id":5,"amount":3}}, #sticks
		{"recipe":[{"id":78,"amount":1}],"result":{"id":5,"amount":3}}, #sticks (With exotic wood)
	],
	"crafting_table": [
		{"recipe":[{"id":10,"amount":1}],"result":{"id":13,"amount":4}},
		{"recipe":[{"id":13,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench
		{"recipe":[{"id":78,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench (With exotic wood)
		{"recipe":[{"id":13,"amount":2}],"result":{"id":30,"amount":4}},
		{"recipe":[{"id":8,"amount":4}],"result":{"id":16,"amount":1}},
		{"recipe":[{"id":17,"amount":4}],"result":{"id":19,"amount":4}},
		{"recipe":[{"id":3,"amount":4}],"result":{"id":15,"amount":4}}, #Stone bricks
		{"recipe":[{"id":22,"amount":4}],"result":{"id":23,"amount":4}},
		{"recipe":[{"id":13,"amount":1}],"result":{"id":5,"amount":3}}, #sticks
		{"recipe":[{"id":78,"amount":1}],"result":{"id":5,"amount":3}}, #sticks (With exotic wood)
		{"recipe":[{"id":18,"amount":1},{"id":14,"amount":1}],"result":{"id":25,"amount":2}},
		{"recipe":[{"id":26,"amount":4}],"result":{"id":27,"amount":4}},
		{"recipe":[{"id":8,"amount":2},{"id":3,"amount":2}],"result":{"id":28,"amount":1}},
		{"recipe":[{"id":71,"amount":4}],"result":{"id":72,"amount":4}}, #Exotic stone bricks
		{"recipe":[{"id":72,"amount":2}],"result":{"id":75,"amount":2}}, #Carved exotic stone bricks
		{"recipe":[{"id":77,"amount":1}],"result":{"id":78,"amount":4}}, #Exotic planks
		{"recipe":[{"id":78,"amount":1},{"id":20,"amount":2}],"result":{"id":79,"amount":2}}, #Exotic wood window
		{"recipe":[{"id":13,"amount":1},{"id":20,"amount":2}],"result":{"id":80,"amount":2}}, #Wood window
		{"recipe":[{"id":52,"amount":1},{"id":20,"amount":2}],"result":{"id":81,"amount":2}}, #Copper wood window
		{"recipe":[{"id":5,"amount":2},{"id":13,"amount":4}],"result":{"id":58,"amount":1}}, #Wood club
		#{"recipe":[{"id":5,"amount":2},{"id":13,"amount":4}],"result":{"id":59,"amount":1}}, #Wood axe
		{"recipe":[{"id":5,"amount":2},{"id":13,"amount":3}],"result":{"id":61,"amount":1}}, #Wood sword
		{"recipe":[{"id":58,"amount":1},{"id":8,"amount":3}],"result":{"id":62,"amount":1}}, #Barbed club
		{"recipe":[{"id":5,"amount":2},{"id":78,"amount":4}],"result":{"id":94,"amount":1}}, #Exotic wood club
		{"recipe":[{"id":5,"amount":2},{"id":78,"amount":3}],"result":{"id":93,"amount":1}}, #Exotic Wood sword
		{"recipe":[{"id":58,"amount":1},{"id":78,"amount":3}],"result":{"id":95,"amount":1}}, #Exotic Barbed club
		{"recipe":[{"id":5,"amount":3},{"id":78,"amount":3}],"result":{"id":92,"amount":1}}, #Exotic pick
		{"recipe":[{"id":13,"amount":8}],"result":{"id":91,"amount":1}}, #Chest
		{"recipe":[{"id":13,"amount":78}],"result":{"id":91,"amount":1}}, #Chest (With exotic wood)
	],
	"oven": [
		{"recipe":[{"id":14,"amount":1}],"result":{"id":20,"amount":1}},
		{"recipe":[{"id":18,"amount":1}],"result":{"id":17,"amount":1}},
		{"recipe":[{"id":8,"amount":1}],"result":{"id":3,"amount":1}},
		{"recipe":[{"id":25,"amount":1}],"result":{"id":26,"amount":1}},
		{"recipe":[{"id":29,"amount":1}],"result":{"id":52,"amount":1}},
		{"recipe":[{"id":55,"amount":1}],"result":{"id":56,"amount":1}},
		{"recipe":[{"id":15,"amount":1}],"result":{"id":83,"amount":1}}, #Cracked stone bricks
		{"recipe":[{"id":19,"amount":1}],"result":{"id":86,"amount":1}}, #Cracked mud bricks
		{"recipe":[{"id":23,"amount":1}],"result":{"id":87,"amount":1}}, #Cracked sandstone bricks
	],
	"smithing_table": [
		{"recipe":[{"id":52,"amount":6}],"result":{"id":88,"amount":1}}, #Copper block
		{"recipe":[{"id":56,"amount":6}],"result":{"id":89,"amount":1}}, #Silver block
		{"recipe":[{"id":76,"amount":6}],"result":{"id":90,"amount":1}}, #Rhodonite block
		{"recipe":[{"id":100,"amount":4}],"result":{"id":108,"amount":1}}, #Quartz block
		{"recipe":[{"id":101,"amount":4}],"result":{"id":109,"amount":1}}, #Rose quartz block
		{"recipe":[{"id":102,"amount":4}],"result":{"id":110,"amount":1}}, #Puple quartz block
		{"recipe":[{"id":103,"amount":4}],"result":{"id":111,"amount":1}}, #Blue quartz block
		{"recipe":[{"id":5,"amount":3},{"id":13,"amount":3}],"result":{"id":4,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":3,"amount":3}],"result":{"id":31,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":52,"amount":3}],"result":{"id":53,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":56,"amount":3}],"result":{"id":57,"amount":1}}, #Silver pick
		{"recipe":[{"id":52,"amount":10}],"result":{"id":36,"amount":1}},
		{"recipe":[{"id":52,"amount":5}],"result":{"id":35,"amount":1}},
		{"recipe":[{"id":52,"amount":7}],"result":{"id":37,"amount":1}},
		{"recipe":[{"id":52,"amount":5}],"result":{"id":38,"amount":1}},
		{"recipe":[{"id":56,"amount":5}],"result":{"id":39,"amount":1}},
		{"recipe":[{"id":56,"amount":10}],"result":{"id":40,"amount":1}},
		{"recipe":[{"id":56,"amount":7}],"result":{"id":41,"amount":1}},
		{"recipe":[{"id":56,"amount":5}],"result":{"id":42,"amount":1}},
		{"recipe":[{"id":5,"amount":2},{"id":52,"amount":4}],"result":{"id":63,"amount":1}}, #Copper axe
		{"recipe":[{"id":5,"amount":1},{"id":52,"amount":2}],"result":{"id":64,"amount":1}}, #Copper dagger
		{"recipe":[{"id":5,"amount":2},{"id":52,"amount":3}],"result":{"id":65,"amount":1}}, #Copper sword
		{"recipe":[{"id":5,"amount":2},{"id":56,"amount":4}],"result":{"id":66,"amount":1}}, #Silver axe
		{"recipe":[{"id":5,"amount":1},{"id":56,"amount":2}],"result":{"id":67,"amount":1}}, #Silver dagger
		{"recipe":[{"id":5,"amount":2},{"id":56,"amount":3}],"result":{"id":68,"amount":1}}, #Silver sword
		{"recipe":[{"id":5,"amount":2},{"id":74,"amount":4}],"result":{"id":97,"amount":1}}, #Rhodonite axe
		{"recipe":[{"id":5,"amount":3},{"id":74,"amount":1}],"result":{"id":99,"amount":1}}, #Rhodonite spear
		{"recipe":[{"id":5,"amount":2},{"id":74,"amount":2}],"result":{"id":96,"amount":1}}, #Rhodonite sword
		{"recipe":[{"id":5,"amount":3},{"id":74,"amount":3}],"result":{"id":98,"amount":1}}, #Rhodonite pick
	]
}

var currentPage = 0
var currentMenu = "null"

func update_crafting(menu = "null") -> void:
	if menu != "null":
		currentPage = 0
		currentMenu = menu
	if currentMenu != "null":
		for page in $recipes.get_children():
			for recipe in page.get_children():
				recipe.queue_free()
		var recipesSelect = get_available_recipes(currentMenu)
		var loc = 0
		for recipeID in range(recipesSelect.size()):
			if recipeID % ITEM_PER_PAGE == 0:
				if !$recipes.has_node(str(recipeID / ITEM_PER_PAGE)):
					var page = Control.new()
					page.name = str(recipeID / ITEM_PER_PAGE)
					$recipes.add_child(page)
				loc = 0
			var item = CRAFT_BTN.instance()
			item.rect_position.y = loc * 18
			item.loc = recipeID
			loc += 1
			$recipes.get_node(str(int(recipeID / ITEM_PER_PAGE))).add_child(item)
			item.init(recipesSelect[recipeID])
		update_buttons()

func get_available_recipes(menu : String) -> Array:
	var availableRecipes = []
	for recipe in recipes[menu]:
		for id in get_recipe_ids(recipe["recipe"]):
			if !inventory.find_item(id).empty():
				availableRecipes.append(recipe)
				break
	return availableRecipes

func get_recipe_ids(recipe : Array) -> Array:
	var ids = []
	for item in recipe:
		ids.append(item["id"])
	return ids

func recipe_clicked(recipeRef : Dictionary):
	var recipesSelect = recipeRef
	var recipe1 = recipesSelect["recipe"][0]
	var item1 = inventory.find_item(recipe1["id"])
	var item2 = null
	var recipe2
	if recipesSelect["recipe"].size() > 1:
		recipe2 = recipesSelect["recipe"][1]
		item2 = inventory.find_item(recipe2["id"])
	if !item1.empty() and item1["amount"] >= recipe1["amount"] and (item2 == null or (!item2.empty() and item2["amount"] >= recipe2["amount"])):
		inventory.remove_id_from_inventory(recipe1["id"],recipe1["amount"])
		if item2 != null:
			inventory.remove_id_from_inventory(recipe2["id"],recipe2["amount"])
		inventory.add_to_inventory(recipesSelect["result"]["id"],recipesSelect["result"]["amount"])

func update_buttons() -> void:
	for child in $recipes.get_children():
		if child.name == str(currentPage):
			child.show()
		else:
			child.hide()
	if currentPage > 0:
		$leftBtn.show()
	else:
		$leftBtn.hide()
	if currentPage < (get_available_recipes(currentMenu).size()-1) / inventory.ITEM_PER_PAGE:
		$rightBtn.show()
	else:
		$rightBtn.hide()

func _on_leftBtn2_pressed():
	if currentPage > 0:
		currentPage -= 1
		update_buttons()

func _on_rightBtn2_pressed():
	if currentPage < (get_available_recipes(currentMenu).size()-1) / inventory.ITEM_PER_PAGE:
		currentPage += 1
		update_buttons()
