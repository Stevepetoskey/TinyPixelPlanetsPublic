extends Entity

const MAX_SPEED = 300
const JUMPSPEED = 75
const FRICTION = 0.05

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)

var state = "roam"
var motion := Vector2(0,0)
var animating = false
var canDamage = true

onready var player = get_node("../../../Player")

func _ready():
	maxHealth = 50
	if new:
		health = 50

func _physics_process(delta):
	if !Global.pause:
		$Label.text = state
		if position.distance_to(player.position) <= 64:
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(global_position, player.global_position,[self],3)
			if result.collider == player:
				if !seePlayer:
					$seeTimer.stop()
					lostPlayer = false
	#				seePlayer = true
	#				seenPos = player.position
					$Seen.show()
					yield(get_tree().create_timer(1),"timeout")
					$Seen.hide()
				seePlayer = true
				seenPos = player.position
			elif seePlayer and !lostPlayer:
				lostPlayer = true
				$seeTimer.start()
		match state:
			"roam":
				if randi()%100 == 1 or seePlayer:
					var dir = deg2rad(rand_range(0,360))
					if seePlayer:
						dir = position.angle_to_point(player.position) + deg2rad(180)
					rotation = dir + deg2rad(90)
					$AnimatedSprite.play("thrust")
					state = "in_motion"
					animating = true
					yield(get_tree().create_timer(0.5),"timeout")
					animating = false
					motion = Vector2(cos(dir)*MAX_SPEED,sin(dir)*MAX_SPEED)
		if motion.length() > 0.5:
			motion -= motion * FRICTION
		elif !animating:
			motion = Vector2(0,0)
			state = "roam"
		motion = move_and_slide(motion)

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func _on_HitBox_body_entered(body):
	if canDamage:
		body.damage(2)
		$HurtTimer.start()

func _on_HurtTimer_timeout():
	if !Global.pause:
		player.health -= 2

func _on_HitBox_body_exited(body):
	$HurtTimer.stop()

func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"thrust","hurt":
			$AnimatedSprite.play("idle")
