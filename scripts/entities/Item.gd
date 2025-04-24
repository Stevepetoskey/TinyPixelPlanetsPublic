extends Entity

var canPickup = true
var collected = false

@onready var inventory = get_node("../../../CanvasLayer/Inventory")
@onready var world = get_node("../../../World")

func _ready():
	$Sprite2D.texture = GlobalData.get_item_texture(data["id"])
	$AnimationPlayer.play("idle")

func _process(delta):
	if position.y > 5000:
		queue_free()
	if !collected:
		if !is_on_floor():
			velocity.y += GRAVITY
		velocity.x = move_toward(velocity.x,0,2)
		move_and_slide()

func _on_PickupTimer_timeout():
	canPickup = true

func _on_Area2D_body_entered(body):
	if body != self:
		if body.is_in_group("item"):
			if body.data["id"] == data["id"] and data["data"] == data["data"]:
				data["amount"] += body.data["amount"]
				body.free()
		elif body.type == "player" and canPickup:
			$CollisionShape2D.shape = null
			$Area2D/CollisionShape2D.shape = null
			$AnimationPlayer.play("spin")
			collected = true
			var tween = create_tween()
			tween.set_parallel()
			tween.tween_property(self,"position",body.position,1)
			tween.tween_property(self,"modulate",Color(1,1,1,0),1)
			inventory.add_to_inventory(data["id"],data["amount"],true,data["data"])
			await tween.finished
			queue_free()
