extends Spatial

var angle = 0
var offset = 0.88
var camAngle = 0

func _process(delta):
	$DirectionalLight.translation = Vector3(cos(angle)*offset,0,sin(angle)*offset)
	$DirectionalLight.rotation.y = -angle + deg2rad(90)
	$Camera.translation = Vector3(cos(camAngle)*offset,0,sin(camAngle)*offset)
	$Camera.rotation.y = -camAngle + deg2rad(90)
