extends Control

const CRAFT_BTN = preload("res://assets/CraftBtn.tscn")
const CRAFT_ITEM = preload("res://assets/GUI/craft_item.tscn")

@onready var inventory = get_node("../Inventory")
@onready var ITEM_PER_PAGE = inventory.ITEM_PER_PAGE
@onready var world = $"../../World"
@onready var recipes_container = $RecipesScroll/RecipesContainer
@onready var recipe_data: VBoxContainer = $RecipeData
@onready var craft_btn: Button = $CraftBtn

var groups : Dictionary = {
	"wool":{
		"texture":[],
		"ids":[247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262],
	},
	"planks":{
		"ids":[13,78,157,300]
	},
	"no_exotic_planks":{
		"ids":[13,157,300]
	},
}

var colors : Dictionary = {
	"wool":{
		"white":247,
		"light_gray":248,
		"gray":249,
		"black":250,
		"red":251,
		"orange":252,
		"yellow":253,
		"yellow_green":254,
		"green":255,
		"cyan":256,
		"blue":257,
		"purple":258,
		"pink":259,
		"brown":260,
		"tan":261,
		"maroon":262
	},
	"dye":{
		"white":234,
		"light_gray":235,
		"gray":236,
		"black":237,
		"red":222,
		"orange":223,
		"yellow":224,
		"yellow_green":225,
		"green":226,
		"cyan":227,
		"blue":228,
		"purple":229,
		"pink":230,
		"brown":232,
		"tan":233,
		"maroon":231
	},
}

var recipes = {
	"inventory": [
		{"recipe":[{"id":10,"amount":1}],"result":{"id":13,"amount":4}}, #Planks
		{"recipe":[{"id":13,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench
		{"recipe":[{"id":78,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench (With exotic wood)
		{"recipe":[{"id":77,"amount":1}],"result":{"id":78,"amount":4}}, #Exotic planks
		{"recipe":[{"id":13,"amount":1}],"result":{"id":5,"amount":3}}, #sticks
		{"recipe":[{"id":78,"amount":1}],"result":{"id":5,"amount":3}}, #sticks (With exotic wood)
		{"recipe":[{"id":157,"amount":1}],"result":{"id":5,"amount":3}}, #sticks (With acacia wood)
		{"recipe":[{"id":154,"amount":1}],"result":{"id":157,"amount":4}}, #Acacia planks
		{"recipe":[{"id":157,"amount":4}],"result":{"id":158,"amount":1}}, #Acacia workbench
		{"recipe":[{"id":297,"amount":1}],"result":{"id":300,"amount":4}}, #Willow planks
		{"recipe":[{"id":5,"amount":1},{"id":323,"amount":1}],"result":{"id":321,"amount":4}}, #Torch
	],
	"crafting_table": [
		{"recipe":[{"id":10,"amount":1}],"result":{"id":13,"amount":4}}, #Planks
		{"recipe":[{"id":297,"amount":1}],"result":{"id":300,"amount":4}}, #Willow planks
		{"recipe":[{"id":13,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench
		{"recipe":[{"id":3,"amount":4},{"id":10,"amount":1}],"result":{"id":320,"amount":1}}, #Cooking pot
		{"recipe":[{"id":13,"amount":4},{"id":247,"amount":2}],"result":{"id":263,"amount":1}}, #Wool work table
		{"recipe":[{"id":78,"amount":4}],"result":{"id":12,"amount":1}}, #Workbench (With exotic wood)
		{"recipe":[{"id":5,"amount":1},{"id":323,"amount":1}],"result":{"id":321,"amount":4}}, #Torch
		{"recipe":[{"id":13,"amount":2}],"result":{"id":30,"amount":4}},
		{"recipe":[{"id":8,"amount":4}],"result":{"id":16,"amount":1}},
		{"recipe":[{"id":17,"amount":4}],"result":{"id":19,"amount":4}},
		{"recipe":[{"id":3,"amount":4}],"result":{"id":15,"amount":4}}, #Stone bricks
		{"recipe":[{"id":280,"amount":4}],"result":{"id":282,"amount":4}}, #Smooth stone bricks
		{"recipe":[{"id":282,"amount":4}],"result":{"id":281,"amount":4}}, #Carved Smooth stone bricks
		{"recipe":[{"id":112,"amount":4}],"result":{"id":277,"amount":4}}, #Asteroid rock bricks
		{"recipe":[{"id":112,"amount":2}],"result":{"id":278,"amount":2}}, #Carved asteroid rock
		{"recipe":[{"id":112,"amount":1}],"result":{"id":279,"amount":1}}, #Polished asteroid rock
		{"recipe":[{"id":285,"amount":4}],"result":{"id":302,"amount":4}}, #Mystical stone bricks
		{"recipe":[{"id":285,"amount":4}],"result":{"id":303,"amount":4}}, #Carved mystical stone bricks
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
		{"recipe":[{"id":78,"amount":8}],"result":{"id":91,"amount":1}}, #Chest (With exotic wood)
		{"recipe":[{"id":56,"amount":1}],"result":{"id":113,"amount":1}}, #Silver bucket
		{"recipe":[{"id":52,"amount":1}],"result":{"id":114,"amount":1}}, #Copper bucket
		{"recipe":[{"id":5,"amount":2},{"id":13,"amount":3}],"result":{"id":145,"amount":2}}, #Wood sign
		{"recipe":[{"id":148,"amount":4}],"result":{"id":162,"amount":4}}, #Polished pink granite
		{"recipe":[{"id":149,"amount":4}],"result":{"id":163,"amount":4}}, #Polished white granite
		{"recipe":[{"id":150,"amount":4}],"result":{"id":164,"amount":4}}, #Polished brown granite
		{"recipe":[{"id":154,"amount":1}],"result":{"id":157,"amount":4}}, #Acacia planks
		{"recipe":[{"id":157,"amount":4}],"result":{"id":158,"amount":1}}, #Acacia workbench
		{"recipe":[{"id":157,"amount":8}],"result":{"id":159,"amount":1}}, #Acacia chest
		{"recipe":[{"id":5,"amount":2},{"id":157,"amount":4}],"result":{"id":58,"amount":1}}, #(Acacia) Wood club
		{"recipe":[{"id":5,"amount":2},{"id":157,"amount":3}],"result":{"id":61,"amount":1}}, #(Acacia) Wood sword
		{"recipe":[{"id":173,"amount":1}],"result":{"id":174,"amount":1}}, #Taped steel
		{"recipe":[{"id":173,"amount":1}],"result":{"id":175,"amount":1}}, #Steel tiles
		{"recipe":[{"id":13,"amount":6}],"result":{"id":171,"amount":1}}, #Wood door
		{"recipe":[{"id":300,"amount":6}],"result":{"id":301,"amount":1}}, #Willow door
		{"recipe":[{"id":126,"amount":1}],"result":{"id":222,"amount":2}}, #Red dye
		{"recipe":[{"id":222,"amount":1},{"id":224,"amount":1}],"result":{"id":223,"amount":2}}, #Orange dye
		{"recipe":[{"id":6,"amount":1}],"result":{"id":224,"amount":2}}, #Yellow dye
		{"recipe":[{"id":224,"amount":1},{"id":226,"amount":1}],"result":{"id":225,"amount":2}}, #Yellow green dye
		{"recipe":[{"id":217,"amount":1}],"result":{"id":226,"amount":2}}, #Green dye
		{"recipe":[{"id":226,"amount":1},{"id":228,"amount":1}],"result":{"id":227,"amount":2}}, #Cyan dye
		{"recipe":[{"id":218,"amount":1}],"result":{"id":228,"amount":2}}, #Blue dye
		{"recipe":[{"id":222,"amount":1},{"id":228,"amount":1}],"result":{"id":229,"amount":2}}, #Purple dye
		{"recipe":[{"id":7,"amount":1}],"result":{"id":230,"amount":2}}, #Pink dye
		{"recipe":[{"id":222,"amount":1},{"id":232,"amount":1}],"result":{"id":231,"amount":2}}, #Maroon dye
		{"recipe":[{"id":221,"amount":1}],"result":{"id":232,"amount":2}}, #Brown dye
		{"recipe":[{"id":223,"amount":1},{"id":232,"amount":1}],"result":{"id":233,"amount":2}}, #Tan dye
		{"recipe":[{"id":220,"amount":1}],"result":{"id":234,"amount":2}}, #White dye
		{"recipe":[{"id":234,"amount":1},{"id":236,"amount":1}],"result":{"id":235,"amount":2}}, #Light gray dye
		{"recipe":[{"id":234,"amount":1},{"id":237,"amount":1}],"result":{"id":236,"amount":2}}, #Gray dye
		{"recipe":[{"id":52,"amount":1},{"id":222,"amount":1}],"result":{"id":166,"amount":2}}, #Red wire
		{"recipe":[{"id":193,"amount":9},{"id":165,"amount":6}],"result":{"id":246,"amount":1}}, #Endgame locator
	],
	"oven": [
		{"recipe":[{"id":14,"amount":1}],"result":{"id":20,"amount":1}},
		{"recipe":[{"id":18,"amount":1}],"result":{"id":17,"amount":1}},
		{"recipe":[{"id":8,"amount":1}],"result":{"id":3,"amount":1}},
		{"recipe":[{"id":3,"amount":1}],"result":{"id":280,"amount":1}}, #Smooth stone
		{"recipe":[{"id":286,"amount":1}],"result":{"id":285,"amount":1}}, #Mystical stone
		{"recipe":[{"id":25,"amount":1}],"result":{"id":26,"amount":1}},
		{"recipe":[{"id":29,"amount":1}],"result":{"id":52,"amount":1}}, # Copper
		{"recipe":[{"id":55,"amount":1}],"result":{"id":56,"amount":1}}, #Silver (stone)
		{"recipe":[{"id":200,"amount":1}],"result":{"id":56,"amount":1}}, #Silver (permafrost)
		{"recipe":[{"id":15,"amount":1}],"result":{"id":83,"amount":1}}, #Cracked stone bricks
		{"recipe":[{"id":19,"amount":1}],"result":{"id":86,"amount":1}}, #Cracked mud bricks
		{"recipe":[{"id":23,"amount":1}],"result":{"id":87,"amount":1}}, #Cracked sandstone bricks
		{"recipe":[{"id":134,"amount":1}],"result":{"id":135,"amount":1}}, #Cracked copper bricks
		{"recipe":[{"id":137,"amount":1}],"result":{"id":138,"amount":1}}, #Cracked silver bricks
		{"recipe":[{"id":151,"amount":1}],"result":{"id":165,"amount":1}}, #Iron (pink)
		{"recipe":[{"id":152,"amount":1}],"result":{"id":165,"amount":1}}, #Iron (white)
		{"recipe":[{"id":153,"amount":1}],"result":{"id":165,"amount":1}}, #Iron (brown)
		{"recipe":[{"id":179,"amount":1}],"result":{"id":165,"amount":1}}, #Iron (scorched)
		{"recipe":[{"id":192,"amount":1}],"result":{"id":193,"amount":1}}, #Gold (Sandstone)
		{"recipe":[{"id":194,"amount":1}],"result":{"id":193,"amount":1}}, #Gold (Stone)
		{"recipe":[{"id":5,"amount":2}],"result":{"id":237,"amount":1}}, #Black dye
	],
	"smithing_table": [
		{"recipe":[{"id":52,"amount":6}],"result":{"id":88,"amount":1}}, #Copper block
		{"recipe":[{"id":56,"amount":6}],"result":{"id":89,"amount":1}}, #Silver block
		{"recipe":[{"id":193,"amount":6}],"result":{"id":195,"amount":1}}, #Gold block
		{"recipe":[{"id":165,"amount":4}],"result":{"id":173,"amount":3}}, #Steel
		{"recipe":[{"id":173,"amount":4}],"result":{"id":216,"amount":1}}, #Steel
		{"recipe":[{"id":88,"amount":1}],"result":{"id":133,"amount":2}}, #Copper plate
		{"recipe":[{"id":88,"amount":4}],"result":{"id":134,"amount":4}}, #Copper bricks
		{"recipe":[{"id":89,"amount":1}],"result":{"id":136,"amount":2}}, #Silver plate
		{"recipe":[{"id":89,"amount":4}],"result":{"id":137,"amount":4}}, #Silver bricks
		{"recipe":[{"id":195,"amount":4}],"result":{"id":245,"amount":4}}, #Gold bricks
		{"recipe":[{"id":76,"amount":6}],"result":{"id":90,"amount":1}}, #Rhodonite block
		{"recipe":[{"id":100,"amount":4}],"result":{"id":108,"amount":1}}, #Quartz block
		{"recipe":[{"id":101,"amount":4}],"result":{"id":109,"amount":1}}, #Rose quartz block
		{"recipe":[{"id":102,"amount":4}],"result":{"id":110,"amount":1}}, #Puple quartz block
		{"recipe":[{"id":103,"amount":4}],"result":{"id":111,"amount":1}}, #Blue quartz block
		{"recipe":[{"id":108,"amount":4}],"result":{"id":273,"amount":4}}, #Quartz bricks
		{"recipe":[{"id":109,"amount":4}],"result":{"id":274,"amount":4}}, #Rose quartz bricks
		{"recipe":[{"id":110,"amount":4}],"result":{"id":275,"amount":4}}, #Puple quartz bricks
		{"recipe":[{"id":111,"amount":4}],"result":{"id":276,"amount":4}}, #Blue quartz bricks
		{"recipe":[{"id":5,"amount":3},{"id":13,"amount":3}],"result":{"id":4,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":3,"amount":3}],"result":{"id":31,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":52,"amount":3}],"result":{"id":53,"amount":1}},
		{"recipe":[{"id":5,"amount":3},{"id":56,"amount":3}],"result":{"id":57,"amount":1}}, #Silver pick
		{"recipe":[{"id":52,"amount":10}],"result":{"id":36,"amount":1}},
		{"recipe":[{"id":52,"amount":5}],"result":{"id":35,"amount":1}},
		{"recipe":[{"id":52,"amount":7}],"result":{"id":37,"amount":1}},
		{"recipe":[{"id":52,"amount":5}],"result":{"id":38,"amount":1}},
		{"recipe":[{"id":56,"amount":5}],"result":{"id":39,"amount":1}}, #Silver helmet
		{"recipe":[{"id":56,"amount":10}],"result":{"id":40,"amount":1}}, #Silver chestplate
		{"recipe":[{"id":56,"amount":7}],"result":{"id":41,"amount":1}}, #Silver leggings
		{"recipe":[{"id":56,"amount":5}],"result":{"id":42,"amount":1}}, #Silver boots
		{"recipe":[{"id":165,"amount":5},{"id":205,"amount":1}],"result":{"id":211,"amount":1}}, #Fire helmet
		{"recipe":[{"id":165,"amount":10},{"id":205,"amount":1}],"result":{"id":212,"amount":1}}, #Fire chestplate
		{"recipe":[{"id":165,"amount":7},{"id":205,"amount":1}],"result":{"id":213,"amount":1}}, #Fire leggings
		{"recipe":[{"id":165,"amount":5},{"id":205,"amount":1}],"result":{"id":214,"amount":1}}, #Fire boots
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
		{"recipe":[{"id":5,"amount":3},{"id":3,"amount":2}],"result":{"id":129,"amount":1}}, #Stone Hoe
		{"recipe":[{"id":5,"amount":3},{"id":56,"amount":2}],"result":{"id":130,"amount":1}}, #Silver Hoe
		{"recipe":[{"id":56,"amount":3}],"result":{"id":132,"amount":1}}, #Silver Watering Can
		{"recipe":[{"id":52,"amount":3}],"result":{"id":131,"amount":1}}, #Copper Watering Can
		{"recipe":[{"id":175,"amount":3},{"id":323,"amount":1}],"result":{"id":325,"amount":2}}, #Lantern
		{"recipe":[{"id":197,"amount":3},{"id":323,"amount":1}],"result":{"id":326,"amount":2}}, #Ice lantern
		{"recipe":[{"id":165,"amount":6},{"id":13,"amount":3}],"result":{"id":328,"amount":1}}, #Tech workbench
	],
	"wool_work_table":[
		{"recipe":[{"id":247,"amount":5}],"result":{"id":207,"amount":1}}, #Coat hood
		{"recipe":[{"id":247,"amount":10}],"result":{"id":208,"amount":1}}, #Coat
		{"recipe":[{"id":247,"amount":7}],"result":{"id":209,"amount":1}}, #Coat pants
		{"recipe":[{"id":247,"amount":5}],"result":{"id":210,"amount":1}}, #Coat boots
	],
	"tech_workbench":[
		{"recipe":[{"id":89,"amount":4},{"id":166,"amount":1}],"result":{"id":169,"amount":1}}, #Logic block
		{"recipe":[{"id":89,"amount":4},{"id":166,"amount":1}],"result":{"id":168,"amount":1}}, #Display block
		{"recipe":[{"id":173,"amount":1},{"id":5,"amount":2}],"result":{"id":167,"amount":1}}, #Lever
		{"recipe":[{"id":89,"amount":4},{"id":166,"amount":1}],"result":{"id":170,"amount":1}}, #Flip block
		{"recipe":[{"id":173,"amount":1},{"id":13,"amount":1}],"result":{"id":176,"amount":1}}, #Button
		{"recipe":[{"id":173,"amount":6}],"result":{"id":172,"amount":1}}, #Steel door
		{"recipe":[{"id":89,"amount":4},{"id":166,"amount":1}],"result":{"id":241,"amount":1}}, #Music player
		{"recipe":[{"id":89,"amount":2},{"id":52,"amount":2}],"result":{"id":242,"amount":1}}, #Silver spike
		{"recipe":[{"id":89,"amount":4},{"id":166,"amount":1}],"result":{"id":243,"amount":1}}, #Timer block
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":222,"amount":1}],"result":{"id":265,"amount":1}}, #Red LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":223,"amount":1}],"result":{"id":266,"amount":1}}, #Orange LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":224,"amount":1}],"result":{"id":267,"amount":1}}, #Yellow LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":225,"amount":1}],"result":{"id":268,"amount":1}}, #Yellow Green LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":226,"amount":1}],"result":{"id":269,"amount":1}}, #Green LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":227,"amount":1}],"result":{"id":264,"amount":1}}, #Cyan LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":228,"amount":1}],"result":{"id":270,"amount":1}}, #Blue LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":229,"amount":1}],"result":{"id":271,"amount":1}}, #Purple LED lamp
		{"recipe":[{"id":56,"amount":2},{"id":168,"amount":1},{"id":230,"amount":1}],"result":{"id":272,"amount":1}}, #Pink LED lamp
	]
}

var currentMenu = "null"
var selectedRecipe : Dictionary

func _ready() -> void:
	for woolColor : String in colors["wool"]:
		for dyeColor : String in colors["dye"]:
			if woolColor != dyeColor:
				recipes["wool_work_table"].append({"recipe":[{"id":colors["wool"][woolColor],"amount":4},{"id":colors["dye"][dyeColor],"amount":1}],"result":{"id":colors["wool"][dyeColor],"amount":4}})

func close() -> void:
	hide()
	recipe_data.hide()
	craft_btn.hide()
	selectedRecipe = {}

func update_crafting(menu := "null") -> void:
	if menu != "null":
		currentMenu = menu
	if currentMenu != "null":
		#Removes recipes
		for recipe in recipes_container.get_children():
			recipe.queue_free()
		var recipesSelect = get_available_recipes(currentMenu)
		if !recipesSelect.has(selectedRecipe):
			recipe_data.hide()
			craft_btn.hide()
		for recipe in recipesSelect:
			var item = CRAFT_BTN.instantiate()
			recipes_container.add_child(item)
			item.init(recipe)
			if recipe == selectedRecipe:
				item.disabled = true
			if !can_craft(recipe).has(false):
				recipes_container.move_child(item,0)
			else:
				item.self_modulate = Color(1,0.5,0.5)
	if !selectedRecipe.is_empty():
		update_recipe_data()

func get_available_recipes(menu : String) -> Array:
	var availableRecipes = []
	for recipe in recipes[menu]:
		for id in get_recipe_ids(recipe["recipe"]):
			if !inventory.find_item(id).is_empty():
				availableRecipes.append(recipe)
				break
	return availableRecipes

func get_recipe_ids(recipe : Array) -> Array:
	var ids = []
	for item in recipe:
		ids.append(item["id"])
	return ids

func can_craft(recipe : Dictionary) -> Array:
	var canCraft : Array = []
	for item : Dictionary in recipe["recipe"]:
		var totalCount : int = 0
		if item.has("group"):
			for groupItem : int in groups[item["group"]]:
				totalCount += inventory.count_id(groupItem)
		else:
			totalCount = inventory.count_id(item["id"])
		canCraft.append(totalCount >= item["amount"])
	return canCraft

func update_recipe_data():
	if !get_available_recipes(currentMenu).has(selectedRecipe):
		recipe_data.hide()
		craft_btn.hide()
	else:
		var resultId = selectedRecipe["result"]["id"]
		$RecipeData/ItemName.text = GlobalData.get_item_data(resultId)["name"]
		$RecipeData/InventoryAmount.text = str(inventory.count_id(resultId)) + " in inventory"
		for craftItem : HBoxContainer in $RecipeData/Recipe.get_children():
			craftItem.queue_free()
		var canCraftArray = can_craft(selectedRecipe)
		for item : Dictionary in selectedRecipe["recipe"]:
			var craftItem = CRAFT_ITEM.instantiate()
			craftItem.get_node("TextureRect").texture = GlobalData.get_item_texture(item["id"])
			craftItem.get_node("Label").text = str(item["amount"]) + " (" + str(inventory.count_id(item["id"])) + ")"
			if item["amount"] > inventory.count_id(item["id"]):
				craftItem.modulate = Color(1,0.75,0.75)
			$RecipeData/Recipe.add_child(craftItem)
		craft_btn.disabled = canCraftArray.has(false)
		recipe_data.show()
		craft_btn.show()

func recipe_clicked(recipeRef : Dictionary):
	for recipeBtn : Button in recipes_container.get_children():
		recipeBtn.disabled = recipeBtn.recipeRef == recipeRef
	selectedRecipe = recipeRef
	update_recipe_data()

func mouse_in_btn(recipeRef : Dictionary):
	$"../ItemData".display(recipeRef["result"])

func mouse_out_btn(_recipeRef : Dictionary):
	$"../ItemData".hide()

func _on_craft_btn_pressed() -> void:
	if !can_craft(selectedRecipe).has(false):
		for item : Dictionary in selectedRecipe["recipe"]:
			#if item.has("group"):
			inventory.remove_id_from_inventory(item["id"],item["amount"])
		inventory.add_to_inventory(selectedRecipe["result"]["id"],selectedRecipe["result"]["amount"])
