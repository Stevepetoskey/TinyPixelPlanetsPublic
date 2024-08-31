extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)
var flying : bool = false
var waitForAnimation : bool = false
var flyDir : float
var canLand : bool = false
var setMotion : float
var canDespawn : bool = false
var blocksIn : Array = []
var inWater : bool = false

var state = "idle"
var inAir = false

@onready var player = get_node("../../../Player")
@onready var body: AnimatedSprite2D = $Body
@onready var trot_timer: Timer = $TrotTimer
@onready var fly_timer: Timer = $FlyTimer

func _ready():
	body.play("idle")
	connect("damaged",on_damaged)
	maxHealth = 2
	if new:
		health = 2
	fly_timer.start(randf_range(10,30))

func _physics_process(delta):
	if !Global.pause:
		var result : Dictionary
		if position.distance_to(player.position) <= 64 and state != "sleep":
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
			result = space_state.intersect_ray(params)
		if !result.is_empty() and result.collider == player:
			lostPlayer = false
			seePlayer = true
			seenPos = player.position
		elif seePlayer and !lostPlayer:
			lostPlayer = true
			$seeTimer.start()
		if !waitForAnimation:
			if !is_on_floor() and !flying:
				velocity.y += GRAVITY
			match state:
				"idle":
					flying = false
					velocity.x = 0
					if seePlayer and !lostPlayer:
						begin_fly_away()
					if randi_range(0,100) == 1:
						body.play("eat")
					if randi_range(0,150) == 1:
						body.play("idle")
						setMotion = [MAX_SPEED,-MAX_SPEED].pick_random()
						trot_timer.start(randf_range(1,5))
						state = "roam"
				"roam":
					flying = false
					if is_on_floor():
						if is_on_wall():
							velocity.y = -JUMPSPEED
						else:
							velocity.y = -JUMPSPEED/4.0
					if seePlayer and !lostPlayer:
						begin_fly_away()
					velocity.x = setMotion
					body.flip_h = velocity.x < 0
				"fly_away":
					flying = true
					if is_on_wall():
						flyDir = deg_to_rad(270)
					else:
						flyDir = position.angle_to_point(player.position) + deg_to_rad(180)
					velocity = Vector2(cos(flyDir)*MAX_SPEED,sin(flyDir)*MAX_SPEED)
					#velocity.x = MAX_SPEED * sign(position.x - player.position.x)
					#velocity.y = 0 if position.y <= flyToHeight else -MAX_SPEED
					if lostPlayer or !seePlayer:
						begin_fly_roam(false)
					body.flip_h = velocity.x < 0
				"fly_roam":
					flying = true
					if is_on_floor() and canLand:
						land()
					if is_on_wall():
						flyDir = Vector2(-cos(flyDir),sin(flyDir)).angle()
					if is_on_ceiling() or is_on_floor():
						flyDir = Vector2(cos(flyDir),-sin(flyDir)).angle()
					if !canLand:
						flyDir += deg_to_rad(randf_range(-2,2))
					velocity = Vector2(cos(flyDir)*MAX_SPEED,sin(flyDir)*MAX_SPEED)
					#if randi_range(0,50) == 1:
						#velocity.x = [MAX_SPEED,-MAX_SPEED].pick_random()
					#velocity.y = 0 if position.y <= flyToHeight else -MAX_SPEED
					body.flip_h = velocity.x < 0
			move_and_slide()

func begin_fly_away() -> void:
	state = "fly_away"
	body.play("fly")
	fly_timer.stop()

func begin_fly_roam(changeH : bool = true) -> void:
	canLand = false
	flyDir = deg_to_rad(randf_range(225,315))
	state = "fly_roam"
	body.play("fly")
	fly_timer.start(randf_range(10,30))

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func on_damaged(knockback : float) -> void:
	body.play("fly")
	state = "fly_away"
	velocity.x += knockback

func _on_body_animation_finished() -> void:
	match body.animation:
		"eat":
			if !flying:
				body.play("idle")

func _on_trot_timer_timeout() -> void:
	if !flying:
		body.play("idle")
		state = "idle"

func land() -> void:
	body.play("idle")
	state = "idle"
	fly_timer.start(randf_range(10,30))

func _on_fly_timer_timeout() -> void:
	if flying:
		canLand = true
		flyDir = deg_to_rad(randf_range(60,120))
		if canDespawn:
			queue_free()
	else:
		begin_fly_roam()

func _on_despawn_timer_timeout() -> void:
	canDespawn = true

func _on_block_test_body_entered(body: Node2D) -> void:
	if !blocksIn.has(body):
		blocksIn.append(body)
	if !inWater:
		inWater = true
		GRAVITY = 0
		begin_fly_roam()

func _on_block_test_body_exited(body: Node2D) -> void:
	if blocksIn.has(body):
		blocksIn.erase(body)
	if blocksIn.is_empty():
		inWater = false
		GRAVITY = 4.0
