extends AnimatedSprite

var blink = false

func _ready():
	animation = ["white","blue","red"][randi()%3]
	frame = randi()%2
	if randi()%3==1:
		playing = true
		blink = true
	else:
		blink = false

func _on_VisibilityNotifier2D_screen_entered():
	show()
	if blink:
		playing = true

func _on_VisibilityNotifier2D_screen_exited():
	hide()
