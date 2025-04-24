extends LogicBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")
const frameIds : Dictionary = {
	[Vector2i(-1,0),Vector2i(0,-1)]:0,
	[Vector2i(0,-1),Vector2i(-1,0)]:0,
	[Vector2i(-1,0),Vector2i(0,1)]:1,
	[Vector2i(0,1),Vector2i(-1,0)]:1,
	[Vector2i(0,1),Vector2i(1,0)]:2,
	[Vector2i(1,0),Vector2i(0,1)]:2,
	[Vector2i(1,0),Vector2i(0,-1)]:3,
	[Vector2i(0,-1),Vector2i(1,0)]:3,
}
const miniFramesIds : Dictionary = {
	[0,1]:0,
	[1,0]:0,
	[1,2]:1,
	[2,1]:1,
	[2,3]:2,
	[3,2]:2,
	[3,0]:3,
	[0,3]:3
}
const sideIds : Dictionary = {
	Vector2i(-1,0):0,
	Vector2i(0,1):1,
	Vector2i(1,0):2,
	Vector2i(0,-1):3
}

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var input_node: CanvasLayer = $Inputs
@onready var texture: Sprite2D = $Texture
@onready var frame_hold: Node2D = $Frame

func _ready():
	inputs["I1"] = {}
	input_node.offset = position
	main.connect("toggle_pins",toggle_pins)
	input_node.visible = main.togglePins
	for input in input_node.get_children():
		input.connect("pressed",input_pressed.bind(input.name))
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		z_index -= 1
	if !data.has("toggled"):
		data = {"toggled":false}
	calculate_light(data["toggled"])
	change_frame()
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func input_called(inputPin : String,value,wire : TextureRect):
	inputs[inputPin][wire] = value
	calculate()

func calculate_light(on : bool) -> void:
	if on:
		match layer:
			0:
				if GlobalData.blockData[world.get_block_id(pos,1)]["transparent"]:
					world.set_light(pos, Color.WHITE, Color("0C000005"))
			1:
				world.set_light(pos, Color.WHITE, Color("0C0000FF"))
	else:
		match layer:
			0:
				if GlobalData.blockData[world.get_block_id(pos,1)]["transparent"]:
					world.set_light(pos, Color("00000000"), Color("00000000"))
			1:
				world.set_light(pos, Color.BLACK, Color.BLACK)

func calculate(inputValues := [],ignoreTick := false):
	if inputValues.is_empty():
		inputValues = inputs["I1"].values()
	if !calculating or ignoreTick:
		calculating = true
		await get_tree().create_timer(0.02).timeout
		var on = inputValues.has(true)
		data["last_input"] = inputs["I1"].values()
		data["toggled"] = on
		calculate_light(on)
		change_frame()
		calculating = false

func wire_broke(inputPin : String,wire : TextureRect):
	inputs[inputPin].erase(wire)
	calculate()

func toggle_pins(toggle : bool) -> void:
	input_node.visible = toggle

func input_pressed(input : String) -> void:
	print("input was pressed")
	main.emit_signal("input_pressed",self,input)

func world_loaded():
	on_update()
	if data.has("last_input"):
		calculate(data["last_input"],true)

func change_frame() -> void:
	var frameArray : Array = []
	for frame : Sprite2D in frame_hold.get_children():
		frame_hold.remove_child(frame)
		frame.queue_free()
	var children : Dictionary = {"sides":[],"frames":[],"dots":[],"mini_frames":[]}
	var sides = {Vector2i(-1,0):world.get_block_id(pos - Vector2(1,0),layer) == 168,Vector2i(1,0):world.get_block_id(pos + Vector2(1,0),layer) == 168,Vector2i(0,-1):world.get_block_id(pos - Vector2(0,1),layer) == 168,Vector2i(0,1):world.get_block_id(pos + Vector2(0,1),layer) == 168}
	var mode : String = "on" if data["toggled"] else "off"
	if !sides.values().has(true):
		texture.texture = load("res://textures/blocks/display/" + mode+"/default.png")
	else:
		texture.texture = load("res://textures/blocks/display/"+ mode+ "/bg.png")
		for side : Vector2i in sides:
			if !sides[side]:
				var addLine : bool = true
				for frameTest : Vector2i in [Vector2i(side.y,side.x),Vector2i(side.y,side.x) * Vector2i(-1,-1)]:
					if !sides[frameTest]:
						addLine = false
						if !children["frames"].has(frameIds[[side,frameTest]]):
							children["frames"].append(frameIds[[side,frameTest]])
				if addLine:
					children["sides"].append(sideIds[side])
			else:
				for dotTest : Vector2i in [Vector2i(side.y,side.x),Vector2i(side.y,side.x) * Vector2i(-1,-1)]:
					if sides[dotTest] and !world.get_block_id(pos + Vector2(side + dotTest),layer) == 168 and !children["dots"].has(frameIds[[side,dotTest]]):
						children["dots"].append(frameIds[[side,dotTest]])
		if children["frames"].size() > 1:
			children["mini_frames"].append(miniFramesIds[children["frames"]])
			children["frames"].clear()
		for type : String in children:
			for id : int in children[type]:
				var sprite : Sprite2D = Sprite2D.new()
				sprite.texture = load("res://textures/blocks/display/" + mode+ "/" + type+ "/" + str(id)+ ".png")
				sprite.use_parent_material = true
				frame_hold.add_child(sprite)

func on_update():
	if layer < 1:
		if GlobalData.blockData[world.get_block_id(pos,1)]["transparent"] and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
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
	change_frame()


func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass
