extends Node2D

const PLANET = preload("res://assets/Planet.tscn")

signal system_loaded

func _ready():
	load_system()
	var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet)
	var radius = StarSystem.sizeData[currentPlanet.type["size"]]["radius"]
	$ship.position = currentPlanet.position - Vector2(0,radius + 3)
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

func planet_entered(planet : Object) -> void:
	$ship.canMove = false
	$CanvasLayer/Black/AnimationPlayer.play("fadeIn")
	yield($CanvasLayer/Black/AnimationPlayer,"animation_finished")
	print("Landed")
	StarSystem.land(planet.planetRef)
