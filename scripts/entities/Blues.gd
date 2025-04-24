extends Entity

var canPickup = true
var collected = false

@onready var inventory = get_node("../../../CanvasLayer/Inventory")
@onready var world = get_node("../../../World")

func _ready():
	$AnimationPlayer.play("idle")

func _process(delta):
	if !collected:
		if !is_on_floor():
			velocity.y += GRAVITY
		move_and_slide()

func _on_PickupTimer_timeout():
	canPickup = true

func _on_Area2D_body_entered(body):
	if body != self:
		if canPickup:
			$CollisionShape2D.shape = null
			$Area2D/CollisionShape2D.shape = null
			$AnimationPlayer.play("spin")
			collected = true
			var tween = create_tween()
			tween.set_parallel()
			tween.tween_property(self,"position",body.position,1)
			tween.tween_property(self,"modulate",Color(1,1,1,0),1)
			await tween.finished
			Global.blues += data["amount"]
			queue_free()
