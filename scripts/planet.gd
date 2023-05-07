extends Sprite

var planetRef : Object

onready var main = get_node("../..")
onready var viewPort = $ViewportContainer

func _ready():
	$Area2D/CollisionShape2D.shape.radius = StarSystem.sizeData[planetRef.type["size"]]["radius"]
	viewPort.material.set_shader_param("planet",planetRef.type["texture"])
	#texture = planetRef.type["texture"]
	match planetRef.type["size"]:
		0:
			viewPort.rect_size = Vector2(14,14)
			viewPort.rect_position = Vector2(-7,-7)
			$ViewportContainer/Viewport.size = Vector2(14,14)
		1:
			viewPort.rect_size = Vector2(28,28)
			viewPort.rect_position = Vector2(-14,-14)
			$ViewportContainer/Viewport.size = Vector2(28,28)
		2:
			viewPort.rect_size = Vector2(56,56)
			viewPort.rect_position = Vector2(-28,-28)
			$ViewportContainer/Viewport.size = Vector2(56,56)

func _process(delta):
	position = planetRef.position
	$ViewportContainer/Viewport/Spatial.angle = planetRef.shadeAngle

func _on_Area2D_body_entered(body):
	if !["gas1","gas2","gas3"].has(planetRef.type["type"]):
		main.planet_entered(self)
