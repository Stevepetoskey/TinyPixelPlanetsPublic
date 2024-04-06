extends Node2D

const SCALE_FACTOR = 2

onready var main = get_node("..")
onready var viewPort = $ViewportContainer

var planetRef : Object
var mainPlanet : Object
var isStar = false
var rot = 0

func _ready():
	if isStar:
		$Sprite.show()
		viewPort.queue_free()
		$Sprite.texture = load("res://textures/stars/" + StarSystem.currentStar + ".png")
		modulate = Color(2,2,2)
	elif planetRef.type["type"] == "commet":
		$Sprite.show()
		viewPort.queue_free()
		$Sprite.texture = load("res://textures/planets/commet.png")
	else:
		#$Sprite.hide()
		viewPort.material.set_shader_param("planet",planetRef.type["texture"])
		match planetRef.type["size"]:
			1:
				viewPort.rect_size = Vector2(28,28)
				$ViewportContainer/Viewport
				viewPort.rect_position = Vector2(-14,-14)
			2:
				viewPort.rect_size = Vector2(56,56)
				viewPort.rect_position = Vector2(-28,-28)

func _physics_process(_delta):
	if is_instance_valid(planetRef) or isStar:
		var planetPos = Vector2(0,0)
		var planetYPos = 0
		if !isStar:
			if has_node("ViewportContainer"):
				$ViewportContainer/Viewport/Spatial.angle = planetRef.shadeAngle
				$ViewportContainer/Viewport/Spatial.camAngle = planetRef.position.angle_to_point(mainPlanet.position)
			planetPos = planetRef.position
			planetYPos = planetRef.systemYPos
		var distance = mainPlanet.position.distance_to(planetPos)
		if distance > 0:
			var size = StarSystem.sizeData[mainPlanet.type["size"]]["distance"][0] / (distance / float(SCALE_FACTOR))
			if !isStar and planetRef.type["size"] == StarSystem.sizeTypes.small:
				if size > 1:
					viewPort.material.set_shader_param("planet",load("res://textures/planets/" + planetRef.type["type"] + "Medium.png"))
					viewPort.rect_size = Vector2(28,28)
					viewPort.rect_position = Vector2(-14,-14)
					size /= 2.0
				else:
					viewPort.material.set_shader_param("planet",planetRef.type["texture"])
					viewPort.rect_size = Vector2(14,14)
					viewPort.rect_position = Vector2(-7,-7)
			scale = Vector2(size,size)
			z_index = -int(distance)
			rot = mainPlanet.position.angle_to_point(planetPos) - mainPlanet.currentRot
			position = Vector2((cos(rot) * (main.SKY_RADIUS + planetYPos - mainPlanet.systemYPos)),(sin(rot) * (main.SKY_RADIUS + planetYPos - mainPlanet.systemYPos)))
		if !isStar and planetRef.type["type"] != "commet" and mainPlanet.hasAtmosphere:
			match get_node("..").get_day_type():
				"day","sunset","sunrise":
					viewPort.material.set_shader_param("isNight",false)
				"night":
					viewPort.material.set_shader_param("isNight",true)
	elif !is_instance_valid(planetRef):
		queue_free()
