extends Node2D

const PLANET = preload("res://assets/Planet.tscn")

var planetInCursor = null
var pause = false

@onready var nav: Control = $CanvasLayer/Nav
@onready var loading_animations: AnimationPlayer = $CanvasLayer/Loading/LoadingAnimations

signal system_loaded

func _ready():
	if StarSystem.loadFromGalaxy:
		print("From galaxy!")
		loading_animations.play("start")
	else:
		$CanvasLayer/Black/AnimationPlayer.play("fadeOut")
	load_system()
	if !Global.gamerules["can_leave_system"]:
		$CanvasLayer/GalaxyBtn.hide()
	if Global.playerData["save_type"] == "system":
		$ship.position = Global.playerData["pos"]
	elif Global.currentPlanet != -1:
		await get_tree().process_frame
		print("currentPlanet: ",Global.currentPlanet)
		var currentPlanet = StarSystem.find_planet_id(Global.currentPlanet,true)
		var radius = StarSystem.sizeData[currentPlanet.type["size"]]["radius"]
		$ship.position = currentPlanet.position - Vector2(0,radius + 3)
	else:
		$ship.position = Vector2(0,-StarSystem.currentStarData["min_distance"]/2.0)
	Global.playerData["save_type"] = "system"

func _process(delta: float) -> void:
	$Cursor.global_position = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and planetInCursor != null:
		$CanvasLayer/PlanetInfo.pop_up(planetInCursor)

func load_system():
	for child in $system.get_children():
		child.queue_free()
	for child in $stars.get_children():
		child.hide()
	await get_tree().process_frame
	$stars.get_node(StarSystem.currentStar).show()
	var planets = StarSystem.get_system_bodies()
	for planet in planets:
		var planetObj = PLANET.instantiate()
		planetObj.planetRef = planet
		$system.add_child(planetObj)
	emit_signal("system_loaded")
	$CanvasLayer/Nav.update_nav()

func planet_entered(planet : Object) -> void:
	$ship.canMove = false
	$CanvasLayer/Black/AnimationPlayer.play("fadeIn")
	await $CanvasLayer/Black/AnimationPlayer.animation_finished
	print("Landed")
	StarSystem.land(planet.planetRef.id)

func get_save_data() -> Dictionary:
	return {"player":{"pos":$ship.position},"system":StarSystem.get_system_data()}

func discover_planet(id : int):
	StarSystem.visitedPlanets.append(id)
	print(StarSystem.visitedPlanets)
	nav.update_nav()

func _on_Galaxy_pressed():
	StarSystem.leave_star_system()

func _on_Cursor_area_entered(area: Area2D) -> void:
	planetInCursor = area

func _on_Cursor_area_exited(_area: Area2D) -> void:
	planetInCursor = null
