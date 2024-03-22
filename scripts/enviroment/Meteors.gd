extends Node2D

const METEOR = preload("res://assets/enviroment/BGMeteor.tscn")

var meteorTypes = {
	1:{"radius":3,"amount":40},
	2:{"radius":4,"amount":45},
	3:{"radius":3,"amount":40},
	4:{"radius":4,"amount":45},
	5:{"radius":6,"amount":50},
	6:{"radius":6,"amount":50},
	7:{"radius":8,"amount":60},
	8:{"radius":11,"amount":70},
	9:{"radius":11,"amount":70},
	10:{"radius":30,"amount":100},
}

export var meteorSpawnTime = [5,10]

var stage = 2

func _ready():
	pass
	#start_meteors()

func start_meteors():
	stage = 2
	$MeteorTimer.start(rand_range(meteorSpawnTime[0],meteorSpawnTime[1]))

func _on_MeteorTimer_timeout():
	var meteor = METEOR.instance()
	meteor.position = Vector2(rand_range(-286,286),-20)
	var meteorType = randi() % stage + 1
	meteor.get_node("Particles2D").amount = meteorTypes[meteorType]["amount"]
	meteor.get_node("Particles2D").process_material.emission_sphere_radius =  meteorTypes[meteorType]["radius"]
	meteor.texture = load("res://textures/enviroment/meteors/meteor" + str(meteorType) + ".png")
	add_child(meteor)
	$MeteorTimer.start(rand_range(meteorSpawnTime[0],meteorSpawnTime[1]))
