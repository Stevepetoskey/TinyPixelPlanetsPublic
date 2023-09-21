extends Label

func _process(delta):
	rect_position = get_global_mouse_position() + Vector2(3,3)
	var screenMouse = $"../Hotbar".get_local_mouse_position()
	if screenMouse.x + rect_size.x + 3 > 240:
		rect_position.x -= rect_size.x +3
	if screenMouse.y + rect_size.y + 3 > 160:
		rect_position.y -= rect_size.y +3
	rect_size = Vector2(0,0)
