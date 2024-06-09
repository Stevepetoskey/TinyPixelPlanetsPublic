extends Panel

const PLANET_TYPE = preload("res://assets/space/PlanetType.tscn")

var planetTextures = {
	"desert":preload("res://textures/planets/desert.png"),
	"terra":preload("res://textures/planets/terra.png"),
	"stone":preload("res://textures/planets/stone.png"),
	"snow":preload("res://textures/planets/snow.png"),
	"mud":preload("res://textures/planets/mud.png"),
	"asteroids":preload("res://textures/planets/asteroids.png"),
	"ocean":preload("res://textures/planets/ocean.png"),
	"snow_terra":preload("res://textures/planets/snow_terra.png"),
	"gas1":preload("res://textures/planets/gas1_small.png"),
	"gas2":preload("res://textures/planets/gas2_small.png"),
	"gas3":preload("res://textures/planets/gas3_small.png"),
	"exotic":preload("res://textures/planets/exotic.png"),
	"grassland":preload("res://textures/planets/grassland.png")
}

var planetTypeNames = {
	"desert":"Desert",
	"terra":"Terra",
	"stone":"Stone",
	"snow":"Snow",
	"mud":"Mud",
	"asteroids":"Asteroids",
	"ocean":"Ocean",
	"snow_terra":"Snow Terra",
	"gas1":"Gas Giant",
	"gas2":"Gas Giant",
	"gas3":"Gas Giant",
	"exotic":"Exotic",
	"grassland":"Grassland"
}

@onready var camera = $"../GalaxyView"

var hoverPos = Vector2(0,0)

func hover(pos, id : String):
	hoverPos = pos
	for child in $ScrollContainer/VBoxContainer.get_children():
		if child != $ScrollContainer/VBoxContainer/SystemName:
			child.queue_free()
	StarSystem.new_system(int(id))
	var systemData = StarSystem.get_system_data()
	$ScrollContainer/VBoxContainer/SystemName.text = systemData["system_name"]
	var planets = systemData["planets"]
	var currentTypes = []
	for planetId in planets:
		var planetType = planets[planetId]["planet_type"]
		if !currentTypes.has(planetType):
			currentTypes.append(planetType)
			var planetSlot = PLANET_TYPE.instantiate()
			planetSlot.get_node("Planet").texture = planetTextures[planets[planetId]["planet_type"]]
			planetSlot.get_node("Label").text = planetTypeNames[planets[planetId]["planet_type"]]
			$ScrollContainer/VBoxContainer.add_child(planetSlot)
	show()

func _process(delta):
	var shouldPos = hoverPos + Vector2(16,-84)
	if shouldPos.y - camera.position.y < -84:
		shouldPos = hoverPos + Vector2(16,16)
	position = shouldPos#Vector2(clamp(shouldPos.x,0,284),clamp(shouldPos.y,0,160))
