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

@onready var player = get_node("../../../Player")
@onready var body: AnimatedSprite2D = $Body

func _ready():
	maxHealth = 50
	if new:
		health = 50
	connect("damaged",on_damaged)

func _physics_process(delta):
	if !Global.pause:
		var result : Dictionary
		if position.distance_to(player.position) <= 64:
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(global_position, player.global_position,3,[self])
			result = space_state.intersect_ray(params)
		if !result.is_empty() and result.collider == player:
			if !seePlayer:
				$seeTimer.stop()
				$Seen.show()
				await get_tree().create_timer(1).timeout
				$Seen.hide()
			seePlayer = true
			lostPlayer = false
			seenPos = player.position
		elif seePlayer and !lostPlayer:
			lostPlayer = true
			$seeTimer.start()
		match state:
			"roam":
				if randi()%100 == 1 or seePlayer:
					var dir = deg_to_rad(randf_range(0,360))
					if seePlayer:
						dir = position.angle_to_point(seenPos)
					rotation = dir + deg_to_rad(90)
					body.play("thrust")
					state = "in_motion"
					animating = true
					await get_tree().create_timer(0.5).timeout
					animating = false
					motion = Vector2(cos(dir)*MAX_SPEED,sin(dir)*MAX_SPEED)
		if motion.length() > 0.5:
			motion -= motion * FRICTION
		elif !animating:
			motion = Vector2(0,0)
			state = "roam"
		set_velocity(motion)
		move_and_slide()
		motion = velocity

func _on_seeTimer_timeout():
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

func _on_AnimatedSprite_animation_finished() -> void:
	match body.animation:
		"thrust","hurt":
			body.play("idle")

func on_damaged(knockback : float) -> void:
	motion.x += knockback
