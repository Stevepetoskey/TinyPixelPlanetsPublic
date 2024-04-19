extends Control

const ICON = preload("res://assets/planetNavIcon.tscn")

@onready var planetIcons = $SystemInfo/ScrollContainer/Planets
@onready var systemName = $SystemInfo/TitleScroll/name

var pos = {true:0,false:-40}

var closest : Object = null

func _process(delta):
	if get_closest_body() != null:
		closest = get_closest_body().planetRef

func get_closest_body():
	var closes : Object = get_node("../../system").get_child(0)
	for planet in get_node("../../system").get_children():
		if get_node("../../ship").position.distance_to(planet.global_position) < 50 and !StarSystem.visitedPlanets.has(planet.planetRef.id):
			StarSystem.visitedPlanets.append(planet.planetRef.id)
			update_nav()
		if get_node("../../ship").position.distance_to(planet.global_position) < get_node("../../ship").position.distance_to(closes.position):
			closes = planet
	return closes

func update_nav():
	#--- System Info tab---
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
			icon.get_node("Icon").texture = load("res://textures/planets/" + planet.type["type"] + "_icon.png")
			icon.get_node("Name").text = planet.pName.to_upper()
		else:
			icon.get_node("Icon").texture = load("res://textures/planets/unkown_icon.png")
			icon.get_node("Name").text = "???"
		if !planet.orbitingBody.is_in_group("star"):
			icon.get_node("Hierarchy").show()
			icon.get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_End.png")
			if currentHierarchy == planet.orbitingBody:
				planetIcons.get_child(planetIcons.get_child_count()-1).get_node("Hierarchy").texture = load("res://textures/GUI/space/hierarchy_T.png")
			else:
				currentHierarchy = planet.orbitingBody
		icon.name = str(planet.id)
		planetIcons.add_child(icon)

func _on_SystemInfoBtn_toggled(button_pressed):
	$SystemInfo.visible = button_pressed

func _on_Tab_toggled(button_pressed):
	$SystemInfo.hide()
	$SystemInfoBtn.button_pressed = false
	$Tab.disabled = true
	for x in range(pos[!button_pressed],pos[button_pressed],1 if button_pressed else -1):
		position.x = x
		await get_tree().idle_frame
	position.x = pos[button_pressed]
	$Tab.disabled = false
