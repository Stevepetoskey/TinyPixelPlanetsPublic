extends Node3D

@export var fromTop = false

var angle = 0
var offset = 0.82
var camAngle = 0

func _process(delta):
	$DirectionalLight3D.position = Vector3(cos(angle)*offset,0,sin(angle)*offset)
	$DirectionalLight3D.rotation.y = -angle + deg_to_rad(90)
#	$Camera.translation = Vector3(cos(camAngle)*offset,0,sin(camAngle)*offset)
#	$Camera.rotation.y = -camAngle + deg2rad(90)
