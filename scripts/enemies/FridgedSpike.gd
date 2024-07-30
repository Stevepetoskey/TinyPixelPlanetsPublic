extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75
const ACCEL = 5

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)

var state = "down"
var motion = Vector2(0,0)
var inAir = false
var spitting = false
var searchingForPlayer : bool = false

var goInDir = 0

@onready var entities = $"../../../Entities"
@onready var player = $"../../../Player"
@onready var body_texture: AnimatedSprite2D = $Body
@onready var seen: Sprite2D = $Seen
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spit_timer: Timer = $SpitTimer

func _ready():
	body_texture.play("Idle")
	state = "roam"
	maxHealth = 20
	if new:
		health = 20
	connect("damaged",on_damaged)

func _physics_process(delta):
	if !Global.pause:
		if position.distance_to(player.position) <= 96 and state != "stone":
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self,$HitBox])
			var result = space_state.intersect_ray(params)
			if !result.is_empty() and result.collider == player:
				if !seePlayer:
					$seeTimer.stop()
					animation_player.play("seen")
				if searchingForPlayer or !seePlayer:
					spit_timer.start()
				searchingForPlayer = false
				seePlayer = true
				lostPlayer = false
				seenPos = player.position
			elif seePlayer and !lostPlayer:
				if !result.is_empty():
					print(result.collider.name)
				lostPlayer = true
				searchingForPlayer = true
				$seeTimer.start()
				spit_timer.stop()
		match state:
			"roam":
				if !seePlayer:
					if randi()%(100 if goInDir == -1000 else 50) == 1:
						goInDir = [-1000,-1000,deg_to_rad(randi_range(1,360))].pick_random()
				elif !lostPlayer:
					if !spitting:
						if position.distance_to(player.position) <= 64:
							if position.distance_to(player.position) < 48:
								goInDir = position.angle_to_point(player.position)
							else:
								goInDir = -1000
						else:
							goInDir = position.angle_to_point(player.position)
					else:
						goInDir = -1000
				else:
					goInDir =  position.angle_to_point(seenPos)
				if goInDir != -1000:
					motion = Vector2(cos(goInDir)*MAX_SPEED,sin(goInDir)*MAX_SPEED)
				else:
					motion = Vector2(0,0)
				if abs(motion.x) > 0.5:
					body_texture.flip_h = motion.x < 0
				elif seePlayer:
					body_texture.flip_h = player.position < position
				velocity = motion
				set_up_direction(Vector2(0,-1))
				move_and_slide()
				motion = velocity
			"stone":
				if !is_on_floor():
					motion.y += GRAVITY
					inAir = true
				else:
					inAir = false
				motion.x = move_toward(motion.x,0,ACCEL/2)
				velocity = motion
				set_up_direction(Vector2(0,-1))
				move_and_slide()
				motion = velocity

func on_damaged() -> void:
	canDamage = false
	state = "stone"
	spit_timer.stop()
	body_texture.play("Hurt")
	$Puff.emitting = true
	motion = Vector2(-30 if player.position > position else 30, -JUMPSPEED)
	collision_layer = 0
	$StoneTimer.start()

func _on_seeTimer_timeout():
	print("Gave up")
	seePlayer = false
	lostPlayer = false

func _on_HitBox_body_entered(body):
	body.damage(2)
	$HurtTimer.start()

func _on_HurtTimer_timeout():
	if !Global.pause:
		player.health -= 2

func _on_HitBox_body_exited(body):
	$HurtTimer.stop()

func _on_spit_timer_timeout() -> void:
	if !Global.pause:
		spitting = true
		body_texture.play("Spit")
		await get_tree().create_timer(0.75).timeout
		entities.spawn_fridged_spit(position,position.angle_to_point(player.position))
		if !seePlayer:
			spit_timer.stop()
		spitting = false
		if state == "roam":
			body_texture.play("Idle")

func _on_stone_timer_timeout() -> void:
	canDamage = true
	collision_layer = 8
	body_texture.play("Idle")
	state = "roam"
	$Puff.emitting = true
