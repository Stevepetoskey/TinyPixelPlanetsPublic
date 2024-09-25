extends Entity

var SPEED = 120

var direction = 0

func _ready() -> void:
	$Sprite2D.play("default")
	if data.is_empty():
		data = {"direction":direction,"new":true}
	else:
		direction = data["direction"]
	print("charge spawned")
	rotation = direction - deg_to_rad(90)
	velocity = Vector2(cos(direction)*SPEED,sin(direction)*SPEED)

func update_direction(dir : float) -> void:
	print("update dir")
	data["new"] = false
	SPEED += 20
	direction = dir
	data["direction"] = dir
	rotation = direction - deg_to_rad(90)
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
