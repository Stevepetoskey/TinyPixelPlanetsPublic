extends CharacterBody2D

const MAX_SPEED = 40
const JUMPSPEED = 75
const ACCEL = 5
const TRI_CHARGE = preload("res://assets/entities/trinanium_charge.tscn")
var GRAVITY = 4

var collisionStates : Dictionary = {
	"left":[Vector2(-61,58),Vector2(29,58),Vector2(13,-20),Vector2(28,-78)],
	"right":[Vector2(-47,58),Vector2(43,58),Vector2(-46,-78),Vector2(-31,-20)]
}
var shootFromPos : Dictionary = {
	"left":Vector2(-32.5,52),
	"right":Vector2(32.5,52)
}

var state = "down"
var facingDir : String = "left"
var motion = Vector2(0,0)
var inAir = false
var spitting = false
var goToPos = Vector2(0,0)
var setHeight : float = 320

var goInDir = 0
var hitbackStage : int = 1

var maxHealth = 100
var health = 100
var frozen : bool = false
var poisoned : bool = false
var canDamage : bool = true

@export var canDie = true
@export var hostile = false
@export var bluesDropRange = [0,0]
@export var loot = []
var new = true
var data = {}
@export var type : String

@onready var entities = $"../../../Entities"
@onready var player : CharacterBody2D = $"../../../Player"
@onready var body_texture: AnimatedSprite2D = $Body
@onready var spit_timer: Timer = $SpitTimer
@onready var warning: AudioStreamPlayer2D = $Warning
@onready var hit_box: Area2D = $HitBox
@onready var choose_move_timer: Timer = $ChooseMoveTimer
@onready var await_hit_back: Timer = $AwaitHitBack
@onready var effects = get_node("../../../Effects")
@onready var main: Node2D = get_node("../../..")

signal damaged

func die():
	randomize()
	GlobalGui.complete_achievement("The end")
	if hostile:
		Global.killCount += 1
		if Global.inTutorial and Global.tutorialStage == 0:
			Global.tutorialStage = 1
			main.new_tutorial_stage()
	var blueDrop = randi_range(bluesDropRange[0],bluesDropRange[1])
	for item in loot:
		var amount = randi_range(item["amount"][0],item["amount"][1])
		if amount > 0:
			$"../..".spawn_item({"id":item["id"],"amount":amount,"data":{}},false,position)
	if blueDrop > 0:
		get_node("../..").spawn_blues(blueDrop,false,position)
	effects.death_particles(position)
	GlobalAudio.stop_boss_music()
	$DieParticles.emitting = true
	await get_tree().create_timer(2.0).timeout
	$DieParticles.emitting = false
	hide()
	$"../..".spawn_item({"id":244,"amount":1,"data":{}},false,position)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func damage(hp,knockback : float = 0):
	if canDie and canDamage:
		if !frozen and !poisoned:
			modulate = Color("ff5959")
		effects.floating_text(position, "-" + str(hp), Color.RED)
		health -= hp
		emit_signal("damaged",knockback)
		await get_tree().create_timer(0.5).timeout
		if !frozen and !poisoned:
			modulate = Color.WHITE
		if health <= 0:
			match data["stage"]:
				1:
					health = 100
					_on_fallen_timer_timeout()
				2:
					health = 200
					_on_fallen_timer_timeout()
				3:
					GlobalAudio.stop_boss_music()
					die()
			data["stage"] += 1

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

func _ready():
	flip(position.x < player.position.x)
	body_texture.play("default")
	if !get_node("../../../World").hasGravity:
		GRAVITY = 0
	maxHealth = 200
	if new:
		health = 100
	if !data.has("stage"):
		data["stage"] = 1
	else:
		hitbackStage = data["stage"]
	if !data.has("original_height"):
		data["original_height"] = position.y - 58
	if data.has("state"):
		state = data["state"]
		match state:
			"idle":
				GlobalAudio.play_boss_music("main")
				choose_move_timer.start()
			"slam","slamming","fallen":
				GlobalAudio.play_boss_music("main")
				choose_move_timer.start()
				position.y = setHeight
				state = "idle"
	canDamage = false
	activate()

func _physics_process(delta: float) -> void:
	if !Global.pause:
		data["state"] = state
		match state:
			"idle":
				position.y = setHeight
				goToPos = Vector2(player.position.x + (80 if position.x > player.position.x else -80),position.y)
				if body_texture.flip_h != (position.x < player.position.x):
					flip(position.x < player.position.x)
				if goToPos.x-4 > position.x or goToPos.x+4 < position.x:
					velocity.x = MAX_SPEED if goToPos.x > position.x else -MAX_SPEED
				else:
					velocity.x = 0
			"slam":
				goToPos = Vector2(player.position.x,position.y)
				if goToPos.x-4 > position.x or goToPos.x+4 < position.x:
					velocity.x = MAX_SPEED if goToPos.x > position.x else -MAX_SPEED
				else:
					velocity.x = 0
		move_and_slide()

func flip(flip : bool) -> void:
	var face : String = {false:"left",true:"right"}[flip]
	facingDir = face
	print("CHANGE FACE: ",face)
	body_texture.flip_h = flip
	$HitBox/CollisionPolygon2D.polygon = collisionStates[face]

func begin_slam() -> void:
	choose_move_timer.stop()
	state = "slam"
	warning.play()
	await get_tree().create_timer(5.0).timeout
	state = "slamming"
	warning.stop()
	var tween = create_tween().tween_property(self,"position",Vector2(position.x,data["original_height"]),0.5).set_ease(Tween.EASE_IN)
	await tween.finished
	$Slam.emitting = true
	tween = create_tween().tween_property(self,"position",Vector2(position.x,setHeight),2).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	state = "idle"
	choose_move_timer.start()

func shoot_charge() -> void:
	body_texture.play("begin_shoot")
	await body_texture.animation_finished
	body_texture.play("shoot_charge")
	await body_texture.animation_finished
	hitbackStage = data["stage"]
	var shootPos : Vector2 = position + shootFromPos[facingDir]
	entities.spawn_linear_spit(shootPos,shootPos.angle_to_point(player.position),"trinanium_charge")
	choose_move_timer.stop()
	await_hit_back.start()
	body_texture.play("end_shoot")

func shoot_spikes() -> void:
	body_texture.play("begin_shoot")
	await body_texture.animation_finished
	print(facingDir)
	var shootPos : Vector2 = position + shootFromPos[facingDir]
	for i in range(data["stage"]):
		var angle = shootPos.angle_to_point(player.position)
		if i == 0:
			entities.spawn_linear_spit(shootPos,angle,"gold_spike")
		else:
			entities.spawn_linear_spit(shootPos,angle+deg_to_rad(30*(i)),"gold_spike")
			entities.spawn_linear_spit(shootPos,angle-deg_to_rad(30*(i)),"gold_spike")
		await get_tree().create_timer(0.2).timeout
	body_texture.play("end_shoot")

func begin_fall() -> void:
	choose_move_timer.stop()
	await_hit_back.stop()
	var tween = create_tween().tween_property(self,"position",Vector2(position.x,data["original_height"]),0.5).set_ease(Tween.EASE_IN)
	GlobalAudio.transistion_boss_music("attack")
	await tween.finished
	canDamage = true
	$FallenTimer.start()

func activate() -> void:
	if state == "down":
		position.y += 78
		body_texture.play("default")
		GlobalAudio.play_boss_music()
		await get_tree().create_timer(1.0).timeout
		var tween = create_tween().tween_property(self,"position",Vector2(position.x,setHeight),4)
		await tween.finished
		await get_tree().create_timer(10.0).timeout
		state = "idle"
		choose_move_timer.start()

func _on_hit_box_body_entered(body: Node2D) -> void:
	body.damage(10,2,150 * (-1 if position.x > body.position.x else 1))

func _on_choose_move_timer_timeout() -> void:
	print("timeout")
	if !Global.pause:
		match randi_range(0,4):
			0:
				shoot_charge()
			1,2:
				shoot_spikes()
			3,4:
				begin_slam()

func _on_hit_box_area_entered(area: Area2D) -> void:
	print(area.get_parent().data)
	if area.get_parent().type == "trinanium_charge" and area.get_parent().data.has("new") and !area.get_parent().data["new"]:
		if hitbackStage > 0:
			hitbackStage -= 1
			choose_move_timer.stop()
			await_hit_back.start()
			area.get_parent().update_direction(area.get_parent().global_position.angle_to_point(player.global_position))
		else:
			state = "fallen"
			begin_fall()

func _on_await_hit_back_timeout() -> void:
	choose_move_timer.start()

func _on_fallen_timer_timeout() -> void:
	$FallenTimer.stop()
	canDamage = false
	var tween = create_tween().tween_property(self,"position",Vector2(position.x,setHeight),2).set_ease(Tween.EASE_IN_OUT)
	GlobalAudio.transistion_boss_music("main")
	await tween.finished
	state = "idle"
	choose_move_timer.start()
