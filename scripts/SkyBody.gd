extends Node2D

const SCALE_FACTOR = 2

@onready var main = get_node("..")
@onready var viewPort = $SubViewportContainer

var planetRef : Object
var mainPlanet : Object
var isStar = false
var rot = 0

func _ready():
	if isStar:
		$Sprite2D.show()
		viewPort.queue_free()
		$Sprite2D.texture = load("res://textures/stars/" + StarSystem.currentStar + ".png")
		modulate = Color(10,10,10)
	elif planetRef.type["type"] == "commet":
		$Sprite2D.show()
		viewPort.queue_free()
		$Sprite2D.texture = load("res://textures/planets/commet.png")
	else:
		#$Sprite.hide()
		viewPort.material.set_shader_parameter("planet",planetRef.type["texture"])
		match planetRef.type["size"]:
			0:
				viewPort.size = Vector2(14,14)
				viewPort.position = Vector2(-7,-7)
			1:
				viewPort.size = Vector2(28,28)
				viewPort.position = Vector2(-14,-14)
			2:
				viewPort.size = Vector2(56,56)
				viewPort.position = Vector2(-28,-28)

func _physics_process(_delta):
	if is_instance_valid(planetRef) or isStar:
		var planetPos = Vector2(0,0)
		var planetYPos = 0
		if !isStar:
			if has_node("SubViewportContainer"):
				$SubViewportContainer/SubViewport/Node3D.angle = planetRef.shadeAngle
				$SubViewportContainer/SubViewport/Node3D.camAngle = planetRef.position.angle_to_point(mainPlanet.position)
			planetPos = planetRef.position
			planetYPos = planetRef.systemYPos
		var distance = mainPlanet.position.distance_to(planetPos)
		if distance > 0:
			var size = StarSystem.sizeData[mainPlanet.type["size"]]["distance"][0] / (distance / float(SCALE_FACTOR))
			if !isStar and planetRef.type["size"] == StarSystem.sizeTypes.small:
				if size > 1:
					viewPort.material.set_shader_parameter("planet",load("res://textures/planets/" + planetRef.type["type"] + "Medium.png"))
					viewPort.size = Vector2(28,28)
					viewPort.position = Vector2(-14,-14)
					size /= 2.0
				else:
					viewPort.material.set_shader_parameter("planet",planetRef.type["texture"])
					viewPort.size = Vector2(14,14)
					viewPort.position = Vector2(-7,-7)
			scale = Vector2(size,size)
			z_index = -int(distance)
			rot = mainPlanet.position.angle_to_point(planetPos) - mainPlanet.currentRot
			position = Vector2((cos(rot) * (main.SKY_RADIUS + planetYPos - mainPlanet.systemYPos)),(sin(rot) * (main.SKY_RADIUS + planetYPos - mainPlanet.systemYPos)))
		if !isStar and planetRef.type["type"] != "commet":
			if mainPlanet.hasAtmosphere:
				match get_node("..").get_day_type():
					"day","sunset","sunrise":
						viewPort.material.set_shader_parameter("isNight",false)
					"night":
						viewPort.material.set_shader_parameter("isNight",true)
			else:
				viewPort.material.set_shader_parameter("isNight",true)
	elif !is_instance_valid(planetRef):
		queue_free()
