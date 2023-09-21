extends AnimatedSprite

var blink = false

func _ready():
	animation = ["white","blue","red"][randi()%3]
	frame = randi()%2
	if randi()%3==1:
		playing = true
