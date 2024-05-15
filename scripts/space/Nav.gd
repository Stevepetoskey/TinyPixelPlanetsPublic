extends Control

const ICON = preload("res://assets/planetNavIcon.tscn")

@onready var planetIcons = $SystemInfo/ScrollContainer/Planets
@onready var systemName = $SystemInfo/TitleScroll/name

var pos = {true:0,false:-40}

var targeted : Object = null
var targetedId : int = -1

func _ready() -> void:
	init_nav()

func get_closest_body():
	var closes : Object = get_node("../../system").get_child(0)
	for planet in get_node("../../system").get_children():
		if get_node("../../ship").position.distance_to(planet.global_position) < 50 and !StarSystem.visitedPlanets.has(planet.planetRef.id):
			StarSystem.visitedPlanets.append(planet.planetRef.id)
			update_nav()
		if get_node("../../ship").position.distance_to(planet.global_position) < get_node("../../ship").position.distance_to(closes.position):
			closes = planet
	return closes

func init_nav():
	#Clears icons
	for child in planetIcons.get_children():
		child.name = "deleting" #Do this otherwise messes up the name of new icons
		child.queue_free()
	#Sets system name
	systemName.text = StarSystem.currentStarName
	var currentHierarchy : Object
	#Adds each planet
	for planet in StarSystem.get_system_bodies():
		var icon = ICON.instantiate()
		if StarSystem.visitedPlanets.has(planet.id): #or ["gas1","gas2","gas3"].has(planet.type["type"]):
			icon.discoverd = true
			icon.get_node("Icon").texture = load("res://textures/planets/" + planet.type["type"] + "_icon.png")
			icon.get_node("Name").text = planet.pName.to_upper()
		else:
			icon.discoverd = false
			icon.get_node("Icon").texture = load("res://textures/planets/unkown_icon.png")
			icon.get_node("Name").text = "???"
		if !planet.orbitingBody.is_in_group("star"):
			icon.get_node("Hierarchy").show()
			icon.get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_End.png")
			if currentHierarchy == planet.orbitingBody:
				planetIcons.get_child(planetIcons.get_child_count()-1).get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_T.png")
			else:
				currentHierarchy = planet.orbitingBody
		icon.id = planet.id
		planetIcons.add_child(icon)

func update_nav():
	#--- System Info tab---
	#Updates system name
	systemName.text = StarSystem.currentStarName
	var currentHierarchy : Object
	var i : int = 0
	#Updates each planet
	for planet in planetIcons.get_children():
		var planetRef = StarSystem.find_planet_id(planet.id)
		if targetedId == planet.id:
			planet.get_node("Icon/near").show()
		else:
			planet.get_node("Icon/near").hide()
		if StarSystem.visitedPlanets.has(planetRef.id): #or ["gas1","gas2","gas3"].has(planet.type["type"]):
			planet.discoverd = true
			planet.get_node("Icon").texture = load("res://textures/planets/" + planetRef.type["type"] + "_icon.png")
			planet.get_node("Name").text = planetRef.pName.to_upper()
		else:
			planet.discoverd = false
			planet.get_node("Icon").texture = load("res://textures/planets/unkown_icon.png")
			planet.get_node("Name").text = "???"
		if !planetRef.orbitingBody.is_in_group("star"):
			planet.get_node("Hierarchy").show()
			planet.get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_End.png")
			if currentHierarchy == planetRef.orbitingBody:
				planetIcons.get_child(i-1).get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_T.png")
			else:
				currentHierarchy = planetRef.orbitingBody
		i+=1

func nav_icon_pressed(id : int):
	if id == targetedId:
		targetedId = -1
		targeted = null
	else:
		targetedId = id
		for planet in $"../../system".get_children():
			if planet.planetRef.id == id:
				targeted = planet
	update_nav()

func _on_SystemInfoBtn_toggled(button_pressed):
	$SystemInfo.visible = button_pressed

func _on_Tab_toggled(button_pressed):
	$SystemInfo.hide()
	$SystemInfoBtn.button_pressed = false
	$Tab.disabled = true
	for x in range(pos[!button_pressed],pos[button_pressed],1 if button_pressed else -1):
		position.x = x
		await get_tree().process_frame
	position.x = pos[button_pressed]
	$Tab.disabled = false
