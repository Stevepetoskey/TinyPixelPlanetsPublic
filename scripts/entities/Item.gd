extends Entity

var canPickup = true
var motion = Vector2(0,0)
var collected = false

onready var inventory = get_node("../../../CanvasLayer/Inventory")
onready var world = get_node("../../../World")

func _ready():
	type = "Item"
	$Sprite.texture = world.get_item_texture(data["id"])
	$AnimationPlayer.play("idle")

func _process(delta):
	if !collected:
		if !is_on_floor():
			motion.y += GRAVITY
		motion = move_and_slide(motion,Vector2(0,-1))

func _on_PickupTimer_timeout():
	canPickup = true

func _on_Area2D_body_entered(body):
	if body != self:
		if body.is_in_group("item"):
			print("should combine")
			if body.data["id"] == data["id"]:
				print("and does")
				data["amount"] += body.data["amount"]
				body.free()
		elif canPickup:
			$CollisionShape2D.shape = null
			$Area2D/CollisionShape2D.shape = null
			$AnimationPlayer.play("spin")
			var ogPos = position
			collected = true
			var time : float = 25
			for i in range(time):
				position = lerp(ogPos,body.position,i/time)
				modulate = lerp(Color(1,1,1,1),Color(1,1,1,0),i/time)
				yield(get_tree(),"idle_frame")
			inventory.add_to_inventory(data["id"],data["amount"])
			queue_free()