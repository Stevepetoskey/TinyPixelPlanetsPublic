extends Sprite

const TIME_FACTOR = 10 #10

export var orbitalSpeed = 1
export var rotationSpeed = 1
export var orbitalDistance = 5
export var currentOrbit = 0
export var currentRot = 0
var orbitingBody : Object
var pName : String
var pDesc : String
var systemYPos = 0
var hasAtmosphere : bool
export(Dictionary) var type

var id : int

var shadeAngle = 0

onready var main = get_node("../..")

func _process(delta):
	if rad2deg(currentOrbit) < 359:
		currentOrbit += deg2rad((delta * (orbitalSpeed / float(orbitalDistance))) / TIME_FACTOR)
	else:
		currentOrbit = deg2rad(0)
	if rad2deg(currentRot) < 359:
		currentRot += deg2rad((delta * rotationSpeed) / TIME_FACTOR)
	else:
		currentRot = deg2rad(0)
	position = orbitingBody.position + Vector2(cos(currentOrbit) * orbitalDistance,sin(currentOrbit) * orbitalDistance)
	shadeAngle = position.angle_to_point(Vector2(0,0))
