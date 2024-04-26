extends TextureRect

var started = false

func _ready():
	notify("WARNING!!!","Your mom!")

func notify(title : String, text : String, icon = load("res://textures/enemies/seen.png"),time : float = 5.0) -> void:
	$Title.text = title
	$Text.text = text
	$Icon.texture = icon
	await move(140).completed
	$Timer.start(time)
	started = true

func move(x):
	var og = position.x
	var smooth : float = 50.0
	for i in range(smooth):
		position.x = lerp(og,x,i/smooth)
		await get_tree().process_frame
	position.x = x

func _on_Timer_timeout():
	await move(240).completed
	queue_free()

func _process(delta):
	if started:
		$TextureProgressBar.value = $Timer.time_left / 5.0
