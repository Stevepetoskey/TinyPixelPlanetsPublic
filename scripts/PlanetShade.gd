extends Node3D

@export var fromTop = false

var angle = 0
var offset = 0.82
var camAngle = 0

func _ready() -> void:
	if fromTop:
		$Camera3D.position = Vector3(0,-offset,0)
		$Camera3D.rotation_degrees.x = 90

func _process(delta):
	#$DirectionalLight3D.position = Vector3(cos(angle)*offset,0,sin(angle)*offset)
	if !fromTop:
		$DirectionalLight3D.rotation.y = -angle + deg_to_rad(90)
		$Camera3D.position = Vector3(cos(camAngle)*offset,0,sin(camAngle)*offset)
		$Camera3D.rotation.y = -camAngle + deg_to_rad(90)
	else:
		$DirectionalLight3D.rotation.y = angle
