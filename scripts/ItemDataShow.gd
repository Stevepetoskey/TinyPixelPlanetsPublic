extends Label

func _process(delta):
	position = get_global_mouse_position() + Vector2(3,3)
	var screenMouse = $"../Hotbar".get_local_mouse_position()
	if screenMouse.x + size.x + 3 > 240:
		position.x -= size.x +3
	if screenMouse.y + size.y + 3 > 160:
		position.y -= size.y +3
	size = Vector2(0,0)
