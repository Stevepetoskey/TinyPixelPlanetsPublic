extends Sprite

var planetRef : Object

onready var main = get_node("../..")

func _ready():
	$Area2D/CollisionShape2D.shape.radius = StarSystem.sizeData[planetRef.type["size"]]["radius"]
	texture = planetRef.type["texture"]

func _process(delta):
	position = planetRef.position
	$Sprite.rotation = planetRef.shadeAngle + deg2rad(180)

func _on_Area2D_body_entered(body):
	if planetRef.type["type"] != "gas":
		main.planet_entered(self)
