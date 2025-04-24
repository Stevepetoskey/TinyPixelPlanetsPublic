extends CharacterBody2D
class_name Entity

var GRAVITY = 4

var maxHealth = 20
var health = 20
var frozen : bool = false
var poisoned : bool = false
var canDamage : bool = true

@export var canDie := true
@export var hostile = false
@export var bluesDropRange : Array = [0,0]
@export var loot : Array = []
var new : bool = true
var data = {}
@export var type : String

@onready var effects = get_node("../../../Effects")
@onready var main: Node2D = get_node("../../..")

signal damaged

func _ready():
	if !get_node("../../../World").hasGravity:
		GRAVITY = 0

func die():
	randomize()
	if hostile:
		Global.killCount += 1
	var blueDrop = randi_range(bluesDropRange[0],bluesDropRange[1])
	for item in loot:
		print("might drop: ",item["id"])
		var amount = randi_range(item["amount"][0],item["amount"][1])
		if amount > 0:
			print("did drop")
			$"../..".spawn_item({"id":item["id"],"amount":amount,"data":{}},false,position)
	if blueDrop > 0:
		get_node("../..").spawn_blues(blueDrop,false,position)
	effects.death_particles(position)
	queue_free()

func damage(hp,knockback : float = 0):
	print("damaged slorg")
	print(canDamage)
	print(canDie)
	if canDie and canDamage:
		if !frozen and !poisoned:
			modulate = Color("ff5959")
		effects.floating_text(position, "-" + str(hp), Color.RED)
		health -= hp
		print(health)
		emit_signal("damaged",knockback)
		await get_tree().create_timer(0.5).timeout
		if !frozen and !poisoned:
			modulate = Color.WHITE
		if health <= 0:
			die()

func freeze(time : float) -> void:
	modulate = Color("75b2ff")
	frozen = true
	await get_tree().create_timer(time).timeout
	modulate = Color.WHITE
	frozen = false

func poison(amount : float,dmg := 1) -> void:
	modulate = Color("47ff3d")
	poisoned = true
	for i in range(amount):
		await get_tree().create_timer(1).timeout
		damage(dmg)
		if i == amount - 1:
			poisoned = false
			modulate = Color.WHITE
