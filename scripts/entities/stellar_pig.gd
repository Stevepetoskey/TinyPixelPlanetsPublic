extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)
var waitForAnimation = false
var setMotion : float
var inWater : bool = false

var blocksOn : Array = []

var state = "idle"
var inAir = false

@onready var player = get_node("../../../Player")
@onready var body: AnimatedSprite2D = $Body
@onready var trot_timer: Timer = $TrotTimer
@onready var sleep_timer: Timer = $SleepTimer

func _ready():
	body.play("idle")
	connect("damaged",on_damaged)
	if data.is_empty():
		data["energy"] = 60
	maxHealth = 10
	if new:
		health = 10

func _physics_process(delta):
	var result : Dictionary
	if position.distance_to(player.position) <= 64 and state != "sleep":
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
		result = space_state.intersect_ray(params)
	if !result.is_empty() and result.collider == player:
		if !seePlayer:
			waitForAnimation = true
			$seeTimer.stop()
			$Seen.show()
			await get_tree().create_timer(1).timeout
			$Seen.hide()
			waitForAnimation = false
		lostPlayer = false
		seePlayer = true
		seenPos = player.position
	elif seePlayer and !lostPlayer:
		lostPlayer = true
		$seeTimer.start()
	if !waitForAnimation:
		if !is_on_floor():
			if !inWater or velocity.y > -15:
				velocity.y += GRAVITY
		match state:
			"idle":
				velocity.x = 0
				if seePlayer and !lostPlayer:
					body.play("trot")
					state = "run"
				if randi_range(0,150) == 1:
					body.play("trot")
					setMotion = [MAX_SPEED,-MAX_SPEED].pick_random()
					trot_timer.start(randf_range(1,5))
					state = "roam"
				elif randi_range(0,400) == 1 and data["energy"] < 25:
					go_to_sleep()
			"roam":
				if is_on_wall() and (is_on_floor() or inWater):
					velocity.y = -JUMPSPEED
				if seePlayer and !lostPlayer:
					body.play("trot")
					state = "run"
				velocity.x = setMotion
				body.flip_h = velocity.x < 0
			"run":
				if is_on_wall() and (is_on_floor() or inWater):
					velocity.y = -JUMPSPEED
				velocity.x = MAX_SPEED * sign(position.x - player.position.x)
				if lostPlayer or !seePlayer:
					body.play("idle")
					state = "idle"
				body.flip_h = velocity.x < 0
			"sleep":
				pass
		move_and_slide()

func go_to_sleep() -> void:
	body.play("sleep")
	state = "sleep"
	sleep_timer.start(randf_range(10,45))

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func on_damaged(knockback : float) -> void:
	body.play("trot")
	state = "run"
	sleep_timer.stop()
	velocity.x += knockback

func _on_body_animation_finished() -> void:
	waitForAnimation = false
	match body.animation:
		"wake":
			body.play("idle")
			state = "idle"

func _on_trot_timer_timeout() -> void:
	body.play("idle")
	state = "idle"

func _on_sleep_timer_timeout() -> void:
	body.play("wake")

func _on_energy_timer_timeout() -> void:
	if state == "sleep":
		data["energy"] += 2
		if data["energy"] >= 60:
			sleep_timer.stop()
			body.play("wake")
	else:
		data["energy"] -= 1
		if data["energy"] <= 0:
			go_to_sleep()

func _on_block_test_body_entered(body: Node2D) -> void:
	if !blocksOn.has(body):
		blocksOn.append(body)
		GRAVITY = -2
		inWater = true

func _on_block_test_body_exited(body: Node2D) -> void:
	if blocksOn.has(body):
		blocksOn.erase(body)
	if blocksOn.is_empty():
		GRAVITY = 4
		inWater = false
