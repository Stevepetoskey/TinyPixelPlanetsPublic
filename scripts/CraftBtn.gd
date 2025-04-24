extends Button

@onready var world = $"../../../../../World"
@onready var crafting = $"../../.."

var recipeRef : Dictionary

func init(recipe : Dictionary) -> void:
	recipeRef = recipe
	var result = recipe["result"]
	$Result.texture = GlobalData.get_item_texture(result["id"])
	$ResultAmount.text = str(result["amount"])

func _pressed() -> void:
	crafting.recipe_clicked(recipeRef)

func _on_CraftBtn_mouse_entered():
	crafting.mouse_in_btn(recipeRef)

func _on_CraftBtn_mouse_exited():
	crafting.mouse_out_btn(recipeRef)
