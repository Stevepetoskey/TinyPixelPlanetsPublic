extends Node2D

const TEXT = preload("res://assets/effects/Text.tscn")
const DEATH = preload("res://assets/effects/Death.tscn")
const SPRAY = preload("res://assets/effects/Spray.tscn")

func floating_text(pos : Vector2, text : String, color: Color):
	var tex = TEXT.instance()
	tex.rect_position = pos
	tex.modulate = color
	tex.text = text
	add_child(tex)

func death_particles(pos : Vector2):
	var death = DEATH.instance()
	death.position = pos
	add_child(death)

func spray(pos : Vector2, flipped : bool):
	for dir in range(-20,40,10):
		var sprayObj = SPRAY.instance()
		var actualDir = dir if !flipped else (dir + 180)
		sprayObj.motion = Vector2(cos(deg2rad(actualDir))*4,sin(deg2rad(actualDir))*8)
		sprayObj.position = pos + Vector2(-10 if flipped else 10,0)
		add_child(sprayObj)
