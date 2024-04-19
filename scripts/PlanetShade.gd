extends Node3D

var angle = 0
var offset = 0.88
var camAngle = 0

func _process(delta):
	$DirectionalLight3D.position = Vector3(cos(angle)*offset,0,sin(angle)*offset)
	$DirectionalLight3D.rotation.y = -angle + deg_to_rad(90)
	$Camera3D.position = Vector3(cos(camAngle)*offset,0,sin(camAngle)*offset)
	$Camera3D.rotation.y = -camAngle + deg_to_rad(90)
