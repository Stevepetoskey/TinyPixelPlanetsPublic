extends Entity

const MAX_SPEED = 15
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
var playerDamaged = false

@onready var player = get_node("../../../Player")
@onready var body: AnimatedSprite2D = $Body
@onready var trot_timer: Timer = $TrotTimer
@onready var plasma_cast: RayCast2D = $PlasmaBeam/PlasmaCast
@onready var plasma_beam: TextureRect = $PlasmaBeam

func _ready():
	body.play("idle")
	connect("damaged",on_damaged)
	if data.is_empty():
		data["friendly"] = false
	maxHealth = 50
	if new:
		health = 50

func _physics_process(delta):
	var result : Dictionary
	if position.distance_to(player.position) <= 96:
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
					body.play("walk")
					state = "follow"
				if randi_range(0,150) == 1:
					body.play("walk")
					setMotion = [MAX_SPEED,-MAX_SPEED].pick_random()
					trot_timer.start(randf_range(1,5))
					state = "roam"
			"roam":
				if is_on_wall() and (is_on_floor() or inWater):
					velocity.y = -JUMPSPEED
				if seePlayer and !lostPlayer:
					body.play("walk")
					state = "follow"
				velocity.x = setMotion
				body.flip_h = velocity.x < 0
			"follow":
				if is_on_wall() and (is_on_floor() or inWater):
					velocity.y = -JUMPSPEED
				if lostPlayer or position.distance_to(player.position) > 64: 
					velocity.x = MAX_SPEED * -sign(position.x - seenPos.x)
				elif position.distance_to(player.position) < 48:
					velocity.x = MAX_SPEED * sign(position.x - seenPos.x)
				else:
					body.play("attack")
					state = "attack"
					velocity.x = 0
				if !seePlayer:
					body.play("idle")
					state = "idle"
					velocity.x = 0
				body.flip_h = velocity.x < 0
		move_and_slide()
	if plasma_cast.enabled:
		if plasma_cast.is_colliding():
			var physBody : PhysicsBody2D = plasma_cast.get_collider()
			plasma_beam.size.x = plasma_beam.global_position.distance_to(plasma_cast.get_collision_point())
			if physBody == player and !playerDamaged:
				physBody.damage(10,2)
				playerDamaged = true
		else:
			plasma_beam.size.x = 600

func _on_seeTimer_timeout():
	seePlayer = false
	lostPlayer = false

func on_damaged(knockback : float) -> void:
	velocity.x += knockback

func _on_body_animation_finished() -> void:
	waitForAnimation = false
	match body.animation:
		"attack":
			plasma_beam.position = Vector2(6,-2) if !body.flip_h else Vector2(-6,-2)
			$PlasmaAnimation.play("beam")
			plasma_beam.rotation = plasma_beam.global_position.angle_to_point(seenPos)
			await get_tree().physics_frame
			if plasma_cast.is_colliding():
				var physBody : PhysicsBody2D = plasma_cast.get_collider()
				plasma_beam.size.x = plasma_beam.global_position.distance_to(plasma_cast.get_collision_point())
				if physBody == player:
					physBody.damage(10,2)
					playerDamaged = true
			else:
				plasma_beam.size.x = 600
			await get_tree().create_timer(1)
			playerDamaged = false
			body.play("walk")
			state = "follow"

func _on_trot_timer_timeout() -> void:
	body.play("idle")
	state = "idle"

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
