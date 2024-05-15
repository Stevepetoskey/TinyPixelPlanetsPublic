extends Sprite2D

var planetRef : Object

@onready var main = get_node("../..")
@onready var viewPort = $SubViewportContainer

func _ready():
	$Area2D/CollisionShape2D.shape.radius = StarSystem.sizeData[planetRef.type["size"]]["radius"]
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

func _process(delta):
	position = planetRef.position
	$SubViewportContainer/SubViewport/Node3D.angle = planetRef.shadeAngle

func _on_Area2D_body_entered(body):
	if !["gas1","gas2","gas3"].has(planetRef.type["type"]):
		main.planet_entered(self)

func _on_discover_body_entered(body: Node2D) -> void:
	main.discover_planet(planetRef.id)
