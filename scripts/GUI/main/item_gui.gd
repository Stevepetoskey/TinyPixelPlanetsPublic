extends TextureRect

func set_item(item : Dictionary) -> void:
	if item["id"] != 0:
		texture = get_item_texture(item["id"],item["data"])
		material.set_shader_parameter("useShine",GlobalData.is_upgraded(item["data"]))
	else:
		texture = null

func get_item_texture(id : int, itemData : Dictionary) -> Texture2D:
	match id:
		113:
			return load("res://textures/items/silver_bucket_level_" + str(itemData["water_level"])+ ".png")
		114:
			return load("res://textures/items/copper_bucket_level_" + str(itemData["water_level"])+ ".png")
		_:
			return GlobalData.get_item_texture(id)
