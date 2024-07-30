extends Entity

const MAX_SPEED = 35
const JUMPSPEED = 75
const ACCEL = 5

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)

var state = "down"
var motion = Vector2(0,0)
var inAir = false
var spitting = false

var goInDir = 0

@onready var entities = $"../../../Entities"
@onready var player = $"../../../Player"
@onready var body_texture: AnimatedSprite2D = $Body
@onready var seen: Sprite2D = $Seen
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spit_timer: Timer = $SpitTimer

func _ready():
	print(type)
	body_texture.play("Start")
	maxHealth = 20
	if new:
		health = 20

func _physics_process(delta):
	if !Global.pause:
		if !is_on_floor():
			inAir = true
			motion.y += GRAVITY
		if position.distance_to(player.position) <= 96:
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
			var result = space_state.intersect_ray(params)
			if !result.is_empty() and result.collider == player:
				if !seePlayer:
					print("SEEN!")
					$seeTimer.stop()
					animation_player.play("seen")
					print("seen player, getting up")
					print("state: ",state)
					if state == "down":
						print("playing animation")
						body_texture.play("Recover")
						spit_timer.start()
				seePlayer = true
				lostPlayer = false
				seenPos = player.position
			elif seePlayer and !lostPlayer:
				print("lost the player")
				lostPlayer = true
				$seeTimer.start()
				spit_timer.stop()
		match state:
			"roam":
				if !seePlayer:
					if randi()%(100 if goInDir == 0 else 50) == 1:
						goInDir = [-1,0,0,0,1][randi()%5]
				elif !lostPlayer:
					if !spitting:
						if position.distance_to(player.position) <= 64:
							if position.distance_to(player.position) < 48:
								goInDir = -1 if player.position.x > position.x else 1
							else:
								goInDir = 0
						else:
							goInDir = -1 if player.position.x < position.x else 1
					else:
						goInDir = 0
				else:
					goInDir = -1 if seenPos.x < position.x else 1
				if is_on_wall() and is_on_floor():
					motion.y = -JUMPSPEED
				if goInDir != 0:
					motion.x = move_toward(motion.x,MAX_SPEED*goInDir,ACCEL)
				else:
					motion.x = move_toward(motion.x,0,ACCEL/2.0)
				if abs(motion.x) > 0.5:
					body_texture.flip_h = motion.x < 0
				elif seePlayer:
					body_texture.flip_h = player.position < position
				set_velocity(motion)
				set_up_direction(Vector2(0,-1))
				move_and_slide()
				motion = velocity

func _on_seeTimer_timeout():
	print("Gave up")
	seePlayer = false
	lostPlayer = false
	body_texture.play("Defend")
	state = "down"

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
		entities.spawn_spit(position,position.angle_to_point(player.position),position.distance_to(player.position))
		if !seePlayer:
			spit_timer.stop()
		spitting = false
		if state == "roam":
			body_texture.play("Move")

func _on_body_animation_finished() -> void:
	print("Animation finished: ",body_texture.animation)
	match body_texture.animation:
		"Recover":
			body_texture.play("Move")
			state = "roam"
