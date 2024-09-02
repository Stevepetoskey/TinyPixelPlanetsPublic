extends Entity

var canPickup = true
var collected = false

@onready var inventory = get_node("../../../CanvasLayer/Inventory")
@onready var world = get_node("../../../World")

func _ready():
	$Sprite2D.texture = world.get_item_texture(data["id"])
	$AnimationPlayer.play("idle")

func _process(delta):
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
			var ogPos = position
			collected = true
			var time : float = 25
			for i in range(time):
				position = lerp(ogPos,body.position,i/time)
				modulate = lerp(Color(1,1,1,1),Color(1,1,1,0),i/time)
				await get_tree().process_frame
			inventory.add_to_inventory(data["id"],data["amount"],true,data["data"])
			queue_free()
