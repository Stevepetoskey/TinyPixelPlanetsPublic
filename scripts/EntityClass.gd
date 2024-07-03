extends CharacterBody2D
class_name Entity

var GRAVITY = 4

var maxHealth = 20
var health = 20

@export var canDie = true
@export var hostile = false
@export var bluesDropRange = [0,0]
@export var loot = []
var new = true
var data = {}
@export var type : String

@onready var effects = get_node("../../../Effects")
@onready var main: Node2D = get_node("../../..")

func _ready():
	if !get_node("../../../World").hasGravity:
		GRAVITY = 0

func die():
	randomize()
	if hostile:
		Global.killCount += 1
		if Global.inTutorial and Global.tutorialStage == 0:
			Global.tutorialStage = 1
			main.new_tutorial_stage()
	var blueDrop = randi_range(bluesDropRange[0],bluesDropRange[1])
	for item in loot:
		print("might drop: ",item["id"])
		var amount = randi_range(item["amount"][0],item["amount"][1])
		if amount > 0:
			print("did drop")
			$"../..".spawn_item({"id":item["id"],"amount":amount},false,position)
	if blueDrop > 0:
		get_node("../..").spawn_blues(blueDrop,false,position)
	effects.death_particles(position)
	queue_free()

func damage(hp):
	if canDie:
		modulate = Color("ff5959")
		effects.floating_text(position, "-" + str(hp), Color.RED)
		health -= hp
		await get_tree().create_timer(0.5).timeout
		modulate = Color.WHITE
		if health <= 0:
			die()
