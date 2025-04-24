extends Entity

var SPEED = 120

var direction = 0

func _ready() -> void:
	if data.is_empty():
		data = {"direction":direction}
	else:
		direction = data["direction"]
	print("charge spawned")
	rotation = direction
	velocity = Vector2(cos(direction)*SPEED,sin(direction)*SPEED)

func update_direction(dir : float) -> void:
	SPEED += 20
	direction = dir
	data = {"direction":dir}
	rotation = direction
	velocity = Vector2(cos(direction)*SPEED,sin(direction)*SPEED)

func _physics_process(delta: float) -> void:
	if is_on_floor() or is_on_ceiling() or is_on_wall() or position.y > 1024 or position.y < 0 or position.x < 0 or position.x > 2048:
		queue_free()
	else:
		move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.type != "mini_transporter":
		body.damage(5)
		queue_free()
