extends HBoxContainer

@onready var main = get_node("../../../..")

func _process(delta):
	if main.closest != null and str(main.closest.id) == name:
		$Icon/near.show()
	else:
		$Icon/near.hide()
