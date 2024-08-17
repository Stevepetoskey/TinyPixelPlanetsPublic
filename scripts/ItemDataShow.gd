extends RichTextLabel

@onready var world: Node2D = $"../../World"
@onready var main: Node2D = $"../.."

func _process(delta):
	position = get_global_mouse_position() + Vector2(3,3)
	var screenMouse = $"../Hotbar".get_local_mouse_position()
	if screenMouse.x + size.x + 3 > 240:
		position.x -= size.x +3
	if screenMouse.y + size.y + 3 > 160:
		position.y -= size.y +3
	size = Vector2(0,0)

func display(data : Dictionary) -> void:
	var itemData = world.get_item_data(data["id"])
	if itemData.has("name"):
		var displayText = itemData["name"]
		if itemData.has("desc"):
			displayText += "\n" + itemData["desc"]
		if data["data"].has("upgrade") and world.upgrades.has(data["data"]["upgrade"]):
			displayText += "\n[color=Palegoldenrod]" + world.upgrades[data["data"]["upgrade"]]["name"] + "[/color]"
		if data["data"].has("upgrades"):
			displayText += main.get_item_upgrade_text(data["data"])
		match itemData["type"]:
			"Bucket":
				displayText += "\n[color=darkorchid]Water level: " + str(data["data"]["water_level"]) + "[/color]"
		show()
		text = displayText
