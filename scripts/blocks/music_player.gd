extends LogicBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var rain_col: LightOccluder2D = $RainCol
@onready var mainCol: CollisionShape2D = $CollisionShape2D
@onready var input_node: CanvasLayer = $Inputs
@onready var music: AudioStreamPlayer2D = $Music
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
		mainCol.disabled = true
		rain_col.queue_free()
		z_index -= 1
	if !data.has("current_track"):
		data = {"current_track":GlobalData.emptyItem.duplicate(true),"is_playing":false}
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func input_called(inputPin : String,value,wire : TextureRect):
	inputs[inputPin][wire] = value
	calculate()

func calculate(inputValues := [],ignoreTick := false):
	if inputValues.is_empty():
		inputValues = inputs["I1"].values()
	if !calculating or ignoreTick:
		calculating = true
		await get_tree().create_timer(0.02).timeout
		var on = inputValues.has(true)
		data["last_input"] = inputs["I1"].values()
		if on and data["current_track"] != GlobalData.emptyItem and !data["is_playing"]:
			data["is_playing"] = true
			GlobalAudio.stop_music()
			music.stream = GlobalAudio.musicPool["chip"][data["current_track"]["id"]]
			music.play()
			animation_player.play("playing")
		elif !on or data["current_track"] == GlobalData.emptyItem:
			data["is_playing"] = false
			music.stop()
			animation_player.play("RESET")
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

func _on_music_finished() -> void:
	music.stop()
	animation_player.play("RESET")
