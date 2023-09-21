extends TextureRect

var started = false

func _ready():
	notify("WARNING!!!","Your mom!")

func notify(title : String, text : String, icon = load("res://textures/enemies/seen.png"),time : float = 5.0) -> void:
	$Title.text = title
	$Text.text = text
	$Icon.texture = icon
	yield(move(140),"completed")
	$Timer.start(time)
	started = true

func move(x):
	var og = rect_position.x
	var smooth : float = 50.0
	for i in range(smooth):
		rect_position.x = lerp(og,x,i/smooth)
		yield(get_tree(),"idle_frame")
	rect_position.x = x

func _on_Timer_timeout():
	yield(move(240),"completed")
	queue_free()

func _process(delta):
	if started:
		$TextureProgress.value = $Timer.time_left / 5.0
