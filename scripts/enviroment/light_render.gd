extends Node2D

@onready var camera_2d: Camera2D = $Camera2D

var cameraCenterPos : Vector2
var previousPos : Vector2i

func _physics_process(delta: float) -> void:
	$Camera2D.position = cameraCenterPos

func _process(delta: float) -> void:
	if Vector2i(cameraCenterPos/8) != previousPos:
		previousPos = Vector2i(cameraCenterPos/8)
		$LightingViewport.position = Vector2(previousPos) * 8 - Vector2(16,8)
		$LightingViewport/SubViewport/LightRect.material.set_shader_parameter("position",previousPos-Vector2i(19,18))
