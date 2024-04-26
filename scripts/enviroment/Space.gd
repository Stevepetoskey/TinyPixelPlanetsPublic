extends Sprite2D

var go = false

func _process(delta):
	if go:
		rotation = -StarSystem.find_planet_id(Global.currentPlanet).currentRot

func _on_World_world_loaded():
	go = true
