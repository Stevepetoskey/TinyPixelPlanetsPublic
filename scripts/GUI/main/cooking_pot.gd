extends Control

@onready var inventory: Control = $"../Inventory"

var ingredients : Dictionary = {
	125:{"health_value":2}, #wheat
	126:{"health_value":2}, #Tomato
	127:{"health_value":2}, #Corn
	294:{"health_value":2}, #Blue glowshroom
	295:{"health_value":2}, #Pink glowshroom
	304:{"health_value":4}, #Meat
	296:{"health_value":1}, #Glow flower
}
var fuel : Dictionary = { #How many recipes you can make with each fuel
	10:{"fuel":5},
	11:{"fuel":1},
	13:{"fuel":2},
	77:{"fuel":5},
	78:{"fuel":2},
	85:{"fuel":1},
	128:{"fuel":1},
}

var recipes = [
	{"recipe":[125],"result":140},
	{"recipe":[126],"result":305},
	{"recipe":[127],"result":306},
	{"recipe":[294],"result":307},
	{"recipe":[295],"result":307},
	{"recipe":[294,295],"result":307},
	{"recipe":[304],"result":308},
	{"recipe":[126,127],"result":309},
	{"recipe":[126,304],"result":310},
	{"recipe":[304,294],"result":311},
	{"recipe":[304,295],"result":311},
	{"recipe":[304,294,295],"result":311},
	{"recipe":[127,304],"result":312},
	{"recipe":[125,304],"result":313},
	{"recipe":[125,304,126],"result":314},
	{"recipe":[125,304,294],"result":315},
	{"recipe":[125,304,295],"result":315},
	{"recipe":[125,304,294,295],"result":315},
	{"recipe":[125,304,127],"result":316},
	{"recipe":[294,295,296],"result":317},
	{"recipe":[126,127,304],"result":318},
]

var slots = []
var currentPot : BaseBlock

func _ready() -> void:
	for slot : int in range(4):
		$Top.get_child(slot).pressed.connect(pot_slot_pressed.bind(slot))

func pop_up() -> void:
	show()
	update_textures()

func clear() -> void:
	for item in slots:
		inventory.add_to_inventory(item["id"],1,true,item["data"])
	slots.clear()
	hide()

func get_result() -> int:
	var currentRecipe : Array = []
	for item in slots:
		if !currentRecipe.has(item["id"]):
			currentRecipe.append(item["id"])
	for recipe in recipes:
		var testRecipe = currentRecipe.duplicate()
		var canCraft : bool = true
		for item in recipe["recipe"]:
			if testRecipe.has(item):
				testRecipe.erase(item)
			else:
				canCraft = false
				break
		if testRecipe.size() == 0 and canCraft:
			print(testRecipe,recipe)
			return recipe["result"]
	return 319

func calc() -> void:
	if !slots.is_empty():
		var result : Dictionary
		var recipeResult = get_result()
		if recipeResult != 319:
			var finalHealth : int
			for item in slots:
				finalHealth += ingredients[item["id"]]["health_value"]
			finalHealth *= 2
			result = {"id":recipeResult,"amount":1,"data":{"regen":finalHealth}}
		else:
			result = {"id":319,"amount":1,"data":{}}
		slots.clear()
		inventory.add_to_inventory(result["id"],1,true,result["data"])
		update_textures()

func update_textures() -> void:
	var data : Dictionary = currentPot.data
	$Bottom/FuelSlot/Item.set_item(data["fuel"])
	$Bottom/FuelSlot/AmountLbl.text = str(data["fuel"]["amount"])
	$Bottom/FuelProgress.max_value = max(data["max_fuel"],1)
	$Bottom/FuelProgress.value = data["cooks_left"]
	for slotId in range(4):
		if slotId < slots.size():
			$Top.get_child(slotId).get_node("Item").set_item(slots[slotId])
		else:
			$Top.get_child(slotId).get_node("Item").set_item({"id":0,"amount":0,"data":0})

func add_to_pot(item : Dictionary) -> bool:
	if slots.size() < 4:
		slots.append(item)
		update_textures()
		return true
	else:
		return false

func _on_cook_btn_pressed() -> void:
	var data : Dictionary = currentPot.data
	var canCook : bool = true
	if data["cooks_left"] <= 0:
		if data["fuel"]["id"] == 0:
			canCook = false
		else:
			var fuelId : int = data["fuel"]["id"]
			data["cooks_left"] = fuel[fuelId]["fuel"]
			data["max_fuel"] = fuel[fuelId]["fuel"]
			data["fuel"]["amount"] -= 1
			if data["fuel"]["amount"] <= 0:
				data["fuel"] = {"id":0,"amount":0,"data":{}}
	if canCook:
		data["cooks_left"] -= 1
		calc()

func pot_slot_pressed(slotId : int) -> void:
	if slotId < slots.size():
		inventory.add_to_inventory(slots[slotId]["id"],1,true,slots[slotId]["data"])
		slots.remove_at(slotId)
		update_textures()

func _on_fuel_slot_pressed() -> void:
	$"../Inventory/TransferUI".begin_transfer(currentPot.data["fuel"],"inventory",0,"cooking_pot")
