extends Sprite

var deleting = false

func _process(delta):
	position += Vector2(delta*10,delta*10)
	print(delta*10)
	if (position.x > 286 or position.y > 160) and !deleting:
		print("deleting")
		deleting = true
		$Delete.start()


func _on_Delete_timeout():
	print("deleted")
	queue_free()
