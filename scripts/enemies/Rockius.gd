extends Entity

const MAX_SPEED = 30
const JUMPSPEED = 75
const ACCEL = 5

var seePlayer = false
var lostPlayer = false
var seenPos = Vector2(0,0)

var state = "roam"
var motion = Vector2(0,0)
var inAir = false

var goInDir = 0

@onready var player = get_node("../../../Player")
@onready var body_texture: AnimatedSprite2D = $Body
@onready var seen: Sprite2D = $Seen
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	body_texture.play("Idle")
	maxHealth = 20
	if new:
		health = 20
	connect("damaged",on_damaged)

func _physics_process(delta):
	if !is_on_floor():
		inAir = true
		motion.y += GRAVITY
	var result : Dictionary
	if position.distance_to(player.position) <= 64:
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
		result = space_state.intersect_ray(params)
	if !result.is_empty() and result.collider == player:
		if !seePlayer:
			print("SEEN!")
			$seeTimer.stop()
			state = "pause"
			animation_player.play("seen")
		seePlayer = true
		lostPlayer = false
		seenPos = player.position
	elif seePlayer and !lostPlayer:
		print("lost the player")
		lostPlayer = true
		$seeTimer.start()
	match state:
		"roam":
			if !seePlayer:
				if randi()%(100 if goInDir == 0 else 50) == 1:
					goInDir = [-1,0,0,0,1][randi()%5]
			else:
				goInDir = -1 if seenPos < position else 1
			if is_on_wall() and is_on_floor():
				motion.y = -JUMPSPEED
			if goInDir != 0:
				motion.x = move_toward(motion.x,MAX_SPEED*goInDir,ACCEL)
			else:
				motion.x = move_toward(motion.x,0,ACCEL/2.0)
			body_texture.rotation_degrees += goInDir * 4
			set_velocity(motion)
			set_up_direction(Vector2(0,-1))
			move_and_slide()
			motion = velocity

func _on_seeTimer_timeout():
	print("Gave up")
	seePlayer = false
	lostPlayer = false
	body_texture.play("Idle")

func _on_HitBox_body_entered(body):
	body.damage(2)
	$HurtTimer.start()

func _on_HurtTimer_timeout():
	player.health -= 2

func _on_HitBox_body_exited(body):
	$HurtTimer.stop()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"seen":
			state = "roam"

func on_damaged(knockback : float) -> void:
	motion.x += knockback
