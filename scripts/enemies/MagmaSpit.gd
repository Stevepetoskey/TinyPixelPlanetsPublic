extends Entity

const SPEED = 120

var distance = 0
var direction = 0

func _ready() -> void:
	print("spit spawned")
	velocity = Vector2(cos(direction)*SPEED,sin(direction)*SPEED - distance)

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY
	if is_on_floor() or position.y > 1024:
		print("spit removed")
		queue_free()
	else:
		move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	body.damage(2)
