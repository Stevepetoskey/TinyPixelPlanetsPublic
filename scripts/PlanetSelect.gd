extends Node2D

const PLANET = preload("res://assets/Planet.tscn")

signal system_loaded

func _ready():
	load_system()
	if Global.playerData["save_type"] == "system":
		$ship.position = Global.playerData["pos"]
	elif Global.currentPlanet != -1:
		var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet)
		var radius = StarSystem.sizeData[currentPlanet.type["size"]]["radius"]
		$ship.position = currentPlanet.position - Vector2(0,radius + 3)
	else:
		$ship.position = Vector2(0,-StarSystem.currentStarData["min_distance"]/2.0)
	$CanvasLayer/Black/AnimationPlayer.play("fadeOut")

func load_system():
	for child in $system.get_children():
		child.queue_free()
	for child in $stars.get_children():
		child.hide()
	yield(get_tree(),"idle_frame")
	$stars.get_node(StarSystem.currentStar).show()
	var planets = StarSystem.get_system_bodies()
	for planet in planets:
		var planetObj = PLANET.instance()
		planetObj.planetRef = planet
		$system.add_child(planetObj)
	emit_signal("system_loaded")
	$CanvasLayer/Nav.update_nav()

func planet_entered(planet : Object) -> void:
	$ship.canMove = false
	$CanvasLayer/Black/AnimationPlayer.play("fadeIn")
	yield($CanvasLayer/Black/AnimationPlayer,"animation_finished")
	print("Landed")
	StarSystem.land(planet.planetRef.id)

func get_save_data() -> Dictionary:
	return {"player":{"pos":$ship.position},"system":StarSystem.get_system_data()}

func _on_Galaxy_pressed():
	StarSystem.leave_star_system()
