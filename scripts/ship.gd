extends KinematicBody2D

const SPEED = 0.02
const MAXSPEED = 2

var motion = Vector2(0,0)
var oldMotion = Vector2(0,0)
var moved = false
var canMove = true
onready var pointerDistance = $pointer.position.x
onready var planet_select: Node2D = $".."

func _ready():
	yield(get_tree().create_timer(2),"timeout")
	$CollisionShape2D.disabled = false

func _physics_process(delta):
	if !planet_select.pause:
		var pointerAngle = deg2rad(stepify(rad2deg(position.angle_to_point(get_closets_body())) - 180,45))
		$pointer.position = Vector2(cos(pointerAngle)*pointerDistance,sin(pointerAngle)*pointerDistance)
		$pointer.rotation = pointerAngle
		if Input.is_action_pressed("move_left") and motion.x > -MAXSPEED:
			motion.x -= SPEED
		if Input.is_action_pressed("move_right") and motion.x < MAXSPEED:
			motion.x += SPEED
		if Input.is_action_pressed("jump") and motion.y > -MAXSPEED:
			motion.y -= SPEED
		if Input.is_action_pressed("down") and motion.y < MAXSPEED:
			motion.y += SPEED
		if oldMotion != motion:
			$AnimatedSprite.play("fly")
		else:
			$AnimatedSprite.play("idle")
		if motion.x < 0:
			$AnimatedSprite.flip_h = true
		elif motion.x > 0:
			$AnimatedSprite.flip_h = false
		oldMotion = motion
		if canMove:
			move_and_collide(motion)

func get_closets_body() -> Vector2:
	var closets = Vector2(0,0)
	for planet in get_node("../system").get_children():
		if position.distance_to(planet.global_position) < position.distance_to(closets):
			closets = planet.global_position
	return closets
