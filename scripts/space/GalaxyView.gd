extends Camera2D

onready var galaxy = $".."

const CAMERA_SPEED = 2.0

var currentSector = Vector2(0,0)

func _process(delta):
	var dir = Vector2(Input.get_axis("move_left","move_right")*CAMERA_SPEED,Input.get_axis("jump","down")*CAMERA_SPEED)
	position += dir
	var sector = Vector2(stepify(position.x,galaxy.SECTOR_SIZE.x),stepify(position.y,galaxy.SECTOR_SIZE.y))
	if sector != currentSector:
		currentSector = sector
		galaxy.update_sectors(currentSector)
