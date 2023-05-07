extends Node2D

const TEXT = preload("res://assets/effects/Text.tscn")
const DEATH = preload("res://assets/effects/Death.tscn")

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
