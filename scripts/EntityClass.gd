extends KinematicBody2D
class_name Entity

const GRAVITY = 4

var maxHealth = 20
var health = 20

var hostile = false
var new = true
var data = {}
var type : String

onready var effects = get_node("../../../Effects")

func die():
	print("bruh")
	effects.death_particles(position)
	queue_free()

func damage(hp):
	print(health)
	modulate = Color("ff5959")
	effects.floating_text(position, "-" + str(hp), Color.red)
	health -= hp
	yield(get_tree().create_timer(0.5),"timeout")
	modulate = Color.white
	if health <= 0:
		die()
