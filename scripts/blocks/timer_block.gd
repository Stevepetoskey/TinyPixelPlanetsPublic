extends LogicBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var input_node: CanvasLayer = $Inputs
@onready var output_node: CanvasLayer = $Outputs
@onready var timer: Timer = $Timer
@onready var tick: Timer = $Tick

func _ready():
	inputs["I1"] = {}
	output_node.offset = position
	input_node.offset = position
	main.connect("toggle_pins",toggle_pins)
	input_node.visible = main.togglePins
	output_node.visible = main.togglePins
	for out in output_node.get_children():
		out.connect("pressed",output_pressed.bind(out.name))
	for input in input_node.get_children():
		input.connect("pressed",input_pressed.bind(input.name))
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		z_index -= 1
	if !data.has("counting"):
		data = {"wait_time":1,"time_left":1,"counting":false}
	elif data["counting"]:
		timer.start(data["time_left"])
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func change_wait_time(time : float) -> void:
	data["wait_time"] = time
	if data["counting"] and data["time_left"] > time:
		data["time_left"] = time
		timer.start(time)
	calculate()

func input_called(inputPin : String,value,wire : TextureRect):
	inputs[inputPin][wire] = value
	calculate()

func calculate(inputValues := [],ignoreTick := false):
	if inputValues.is_empty():
		inputValues = inputs["I1"].values()
	if (!calculating or ignoreTick) and !data["counting"]:
		calculating = true
		await get_tree().create_timer(0.02).timeout
		var on : bool = inputValues.has(true)
		if on:
			data["counting"] = true
			data["time_left"] = data["wait_time"]
			timer.start(data["wait_time"])
			tick.start()
		data["last_input"] = inputs["I1"].values()
		calculating = false

func wire_broke(inputPin : String,wire : TextureRect):
	inputs[inputPin].erase(wire)
	calculate()

func toggle_pins(toggle : bool) -> void:
	input_node.visible = toggle
	output_node.visible = toggle

func send_output(pin : String):
	match pin:
		"O1":
			calculate()

func input_pressed(input : String) -> void:
	print("input was pressed")
	main.emit_signal("input_pressed",self,input)

func output_pressed(out : String) -> void:
	print("output was pressed")
	main.emit_signal("output_pressed",self,out)

func world_loaded():
	on_update()
	if data.has("last_input"):
		calculate(data["last_input"],true)

func on_update():
	if layer < 1:
		if world.transparentBlocks.has(world.get_block_id(pos,1)) and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
			show()
		else:
			hide()
		if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
			for x in range(-1,2):
				for y in range(-1,2):
					if abs(x) != abs(y):
						if ![0,6,7,9,30].has(world.get_block_id(pos + Vector2(x,y),1)) and !$shade.has_node(str(x) + str(y)):
							var shade = Sprite2D.new()
							shade.texture = SHADE_TEX
							shade.name = str(x) + str(y)
							shade.rotation = deg_to_rad({Vector2(0,1):0,Vector2(-1,0):90,Vector2(0,-1):180,Vector2(1,0):270}[Vector2(x,y)])
							$shade.add_child(shade)
						elif world.get_block_id(pos + Vector2(x,y),1) == 0 and $shade.has_node(str(x) + str(y)):
							$shade.get_node(str(x) + str(y)).queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass

func _on_timer_timeout() -> void:
	tick.stop()
	output.emit("O1",true)
	await get_tree().create_timer(0.2).timeout
	output.emit("O1",false)
	data["counting"] = false
	calculate()

func _on_tick_timeout() -> void:
	data["time_left"] = timer.time_left
