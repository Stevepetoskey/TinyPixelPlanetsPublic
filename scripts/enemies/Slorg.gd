extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)

var state = "roam"
var motion = Vector2(0,0)
var inAir = false

onready var player = get_node("../../../Player")

func _ready():
	type = "Slorg"
	hostile = true
	maxHealth = 10
	if new:
		health = 10

func _physics_process(delta):
	$Label.text = state
	if !is_on_floor() and state != "attack":
		$AnimatedSprite.playing = false
		state = "falling"
	if position.distance_to(player.position) <= 64 and is_on_floor():
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
	if !$AnimatedSprite.playing:
		match state:
			"roam":
				if randi()%100 == 1 or seePlayer:
					$AnimatedSprite.play("hop")
			"falling":
				if is_on_floor():
					inAir = false
					$AnimatedSprite.play("land")
					motion = Vector2(0,0)
				else:
					motion.y += GRAVITY
					inAir = true
			"jump":
				state = "falling"
			"attack":
				if !is_on_floor():
					motion.y += GRAVITY
					inAir = true
				elif inAir:
					inAir = false
					$AnimatedSprite.play("land")
					motion = Vector2(0,0)
					state = "roam"
		motion = move_and_slide(motion,Vector2(0,-1))


func _on_AnimatedSprite_animation_finished():
	if state != "attack":
		match $AnimatedSprite.animation:
			"hop":
				$AnimatedSprite.playing = false
				var dir
				var nextState = "jump" if position.distance_to(player.position) >= MAX_SPEED else "attack"
				if !seePlayer:
					dir = 1 if randi()%2 == 1 else -1
				else:
					dir = 1 * sign(player.position.x - position.x)
				motion = Vector2(MAX_SPEED * dir,-JUMPSPEED)
				inAir = true
				state = nextState
				if state == "attack":
					$AnimatedSprite.play("attack")
			"land":
				$AnimatedSprite.playing = false
				state = "roam"

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func _on_HitBox_body_entered(body):
	if state == "attack":
		body.health -= 2
		$HurtTimer.start()

func _on_HurtTimer_timeout():
	player.health -= 2

func _on_HitBox_body_exited(body):
	$HurtTimer.stop()
