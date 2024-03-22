extends KinematicBody2D
class_name Entity

var GRAVITY = 4

var maxHealth = 20
var health = 20

export var canDie = true
export var hostile = false
export var bluesDropRange = [0,0]
var new = true
var data = {}
export var type : String

onready var effects = get_node("../../../Effects")

func _ready():
	if !get_node("../../../World").hasGravity:
		GRAVITY = 0

func die():
	if hostile:
		Global.killCount += 1
	var blueDrop = int(rand_range(bluesDropRange[0],bluesDropRange[1]))
	if blueDrop > 0:
		get_node("../..").spawn_blues(blueDrop,false,position)
	effects.death_particles(position)
	queue_free()

func damage(hp):
	if canDie:
		modulate = Color("ff5959")
		effects.floating_text(position, "-" + str(hp), Color.red)
		health -= hp
		yield(get_tree().create_timer(0.5),"timeout")
		modulate = Color.white
		if health <= 0:
			die()
