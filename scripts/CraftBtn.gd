extends TextureButton

onready var world = get_node("../../../../../World")
onready var crafting = get_node("../../..")

var loc = 0
var recipeRef : Dictionary

func init(recipe : Dictionary) -> void:
	recipeRef = recipe
	var recipe1 = recipe["recipe"][0]
	$Recipe1.texture = world.get_item_texture(recipe1["id"])
	$R1Amount.text = str(recipe1["amount"])
	var result = recipe["result"]
	$Result.texture = world.get_item_texture(result["id"])
	$R3Amount.text = str(result["amount"])
	if recipe["recipe"].size() > 1:
		var recipe2 = recipe["recipe"][1]
		$"+".show()
		$Recipe2.show();$R2Amount.show()
		$Recipe2.texture = world.get_item_texture(recipe2["id"])
		$R2Amount.text = str(recipe2["amount"])

func _pressed() -> void:
	crafting.recipe_clicked(recipeRef)

func _on_CraftBtn_mouse_entered():
	crafting.mouse_in_btn(recipeRef)

func _on_CraftBtn_mouse_exited():
	crafting.mouse_out_btn(recipeRef)
