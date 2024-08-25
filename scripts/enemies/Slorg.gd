extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)
var waitForAnimation = false

var state = "roam"
var motion = Vector2(0,0)
var inAir = false

@onready var player = get_node("../../../Player")
@onready var body: AnimatedSprite2D = $Body

func _ready():
	connect("damaged",on_damaged)
	maxHealth = 10
	if new:
		health = 10

func _physics_process(delta):
	if !Global.pause:
		if !is_on_floor() and !["attack","falling"].has(state) and !waitForAnimation:
			body.play("falling")
			state = "falling"
		if position.distance_to(player.position) <= 64 and is_on_floor():
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
			var result = space_state.intersect_ray(params)
			if !result.is_empty() and result.collider == player:
				if !seePlayer:
					$seeTimer.stop()
					$Seen.show()
					await get_tree().create_timer(1).timeout
					$Seen.hide()
				lostPlayer = false
				seePlayer = true
				seenPos = player.position
			elif seePlayer and !lostPlayer:
				lostPlayer = true
				$seeTimer.start()
		if !waitForAnimation or state == "attack":
			match state:
				"roam":
					if randi()%100 == 1 or seePlayer:
						waitForAnimation = true
						body.play("hop")
				"falling":
					if is_on_floor():
						inAir = false
						waitForAnimation = true
						body.play("land")
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
						body.play("land")
						waitForAnimation = true
						motion = Vector2(0,0)
						state = "roam"
					else:
						state = "roam"
			if motion.y < 0 or ["jump","attack"].has(state):
				set_velocity(motion)
				set_up_direction(Vector2(0,-1))
				move_and_slide()
				motion.y = velocity.y
			else:
				set_velocity(motion)
				set_up_direction(Vector2(0,-1))
				move_and_slide()
				motion = velocity


func _on_AnimatedSprite_animation_finished():
	waitForAnimation = false
	if state != "attack":
		match body.animation:
			"hop":
				var dir
				var nextState = "jump" if position.distance_to(player.position) >= MAX_SPEED else "attack"
				if !seePlayer:
					dir = 1 if randi()%2 == 1 else -1
				else:
					dir = 1 * sign(seenPos.x - position.x)
				motion = Vector2(MAX_SPEED * dir,-JUMPSPEED)
				inAir = true
				state = nextState
				if state == "attack":
					body.play("attack")
					motion.y -= JUMPSPEED/2.0
					set_velocity(motion)
					set_up_direction(Vector2(0,-1))
					move_and_slide()
					motion.y = velocity.y
			"land":
				state = "roam"

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func _on_HitBox_body_entered(body):
	if state == "attack":
		body.damage(2)
		$HurtTimer.start()

func _on_HurtTimer_timeout():
	if !Global.pause:
		player.health -= 2

func _on_HitBox_body_exited(body):
	$HurtTimer.stop()

func on_damaged(knockback : float) -> void:
	motion.x += knockback
