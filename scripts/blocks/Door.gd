extends LogicBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var input_node: CanvasLayer = $Inputs

var max_col_layer : int
var mainBlock = self
var wait = false

signal destroyed

func _ready():
	match id:
		171,301:
			$Texture.position.x = 4
	$Texture.sprite_frames = load("res://textures/" + GlobalData.blockData[id]["door_animation"])
	inputs["I1"] = {}
	input_node.offset = position
	main.connect("toggle_pins",toggle_pins)
	input_node.visible = main.togglePins
	for input in input_node.get_children():
		input.connect("pressed",input_pressed.bind(input.name))
	z_index = layer
	max_col_layer = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		z_index -= 1
	data["main"] = true
	if !data.has("opened"):
		data = {"opened":false}
		collision_layer = 1
		$Texture.play("start_closed")
	else:
		collision_layer = max_col_layer if !data["opened"] else 0
		$Texture.play("start_open" if data["opened"] else "start_closed")
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func input_called(inputPin : String,value,wire : TextureRect):
	inputs[inputPin][wire] = value
	calculate()

func interact():
	if !wait:
		wait = true
		data["opened"] = !data["opened"]
		collision_layer = max_col_layer if !data["opened"] else 0
		$Texture.play("open" if data["opened"] else "close")
		await get_tree().create_timer(0.02).timeout
		wait = false

func calculate(inputValues := [],ignoreTick := false):
	if get_tree() != null:
		if inputValues.is_empty():
			inputValues = inputs["I1"].values()
		if !calculating or ignoreTick:
			calculating = true
			await get_tree().create_timer(0.02).timeout
			var on = inputValues.has(true)
			data["last_input"] = inputs["I1"].values()
			if on != data["opened"]:
				data["opened"] = on
				collision_layer = max_col_layer if !data["opened"] else 0
				$Texture.play("open" if on else "close")
			calculating = false

func wire_broke(inputPin : String,wire : TextureRect):
	inputs[inputPin].erase(wire)
	calculate()

func toggle_pins(toggle : bool) -> void:
	input_node.visible = toggle

func input_pressed(input : String) -> void:
	print("input was pressed")
	main.emit_signal("input_pressed",self,input)

func ghost_block_block_destroyed():
	world.set_block(pos,layer,0,true)
	emit_signal("destroyed")

func world_loaded():
	on_update()
	if data.has("last_input"):
		calculate(data["last_input"],true)

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

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	pass
