extends Sprite2D

@export var orbitalSpeed = 1
@export var rotationSpeed = 1
@export var orbitalDistance = 5
@export var currentOrbit = 0
@export var currentRot = 0
var orbitingBody : Object
var pName : String
var pDesc : String
var systemYPos = 0
var hasAtmosphere : bool
@export var type: Dictionary

var id : int

var shadeAngle = 0

@onready var main = get_node("../..")

func _process(delta):
	if type["type"] == "commet":
		orbitalDistance -= delta * 10
		if orbitalDistance <= 0:
			main.emit_signal("start_meteors")
			queue_free()
	if rad_to_deg(currentOrbit) < 359:
		currentOrbit += deg_to_rad((delta * (orbitalSpeed / float(orbitalDistance))) / GlobalData.timeFactor)
	else:
		currentOrbit = deg_to_rad(0)
	if rad_to_deg(currentRot) < 359:
		currentRot += deg_to_rad((delta * rotationSpeed) / GlobalData.timeFactor)
	else:
		currentRot = deg_to_rad(0)
	position = orbitingBody.position + Vector2(cos(currentOrbit) * orbitalDistance,sin(currentOrbit) * orbitalDistance)
	shadeAngle = position.angle_to_point(Vector2(0,0))
