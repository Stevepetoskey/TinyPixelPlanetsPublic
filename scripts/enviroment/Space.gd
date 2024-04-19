extends Sprite2D

const STAR = preload("res://assets/enviroment/Star.tscn")

@export var starAmount = 100

var go = false

func _ready():
	for i in range(starAmount):
		var star = STAR.instantiate()
		star.position = Vector2(int(randf_range(-250,250)),int(randf_range(-190,190)))
		add_child(star)

func _process(delta):
	if go:
		rotation = -StarSystem.find_planet_id(Global.currentPlanet).currentRot

func _on_World_world_loaded():
	go = true
