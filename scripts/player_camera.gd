extends Camera2D

var toFocus : Array = []

func _physics_process(delta: float) -> void:
	if GlobalAudio.inBossFight and !toFocus.is_empty():
		var distance = $"..".position.distance_to(toFocus[0].position)/4.0
		var angle = $"..".position.angle_to_point(toFocus[0].position)
		#var zoomAmount = 50/max(distance,50)
		#zoom = Vector2(zoomAmount,zoomAmount)
		position = Vector2(cos(angle)*distance,sin(angle)*distance)
	elif position != Vector2.ZERO:
		position = Vector2.ZERO
		#zoom = Vector2.ONE

func _on_focus_area_area_entered(area: Area2D) -> void:
	if !toFocus.has(area.get_parent()) and area.get_parent().type == "mini_transporter":
		toFocus.append(area.get_parent())

func _on_focus_area_area_exited(area: Area2D) -> void:
	if toFocus.has(area.get_parent()):
		toFocus.erase(area.get_parent())
