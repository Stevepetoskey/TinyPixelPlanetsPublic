extends Node2D

@onready var armor = $CanvasLayer/Inventory/Armor
@onready var inventory = $CanvasLayer/Inventory
@onready var title = $CanvasLayer/Title
@onready var titleAnim = $CanvasLayer/Title/AnimationPlayer
@onready var weatherAnimation = $weather/WeatherAnimation
@onready var weatherTimer = $weather/WeatherTimer
@onready var title_timer: Timer = $CanvasLayer/Title/TitleTimer
@onready var go_up: TextureButton = $CanvasLayer/Hotbar/GoUp
@onready var world: Node2D = $World

var currentWeather = "none"
var showFPS : bool = false
var worldType : String
var lastLightUpdatePos : Vector2i
var lastLightImage : Image
var weatherStartData = {}

var togglePins = false

signal weather_changed
signal toggle_pins
signal output_pressed
signal input_pressed
signal gathered_wood

func _ready():
	$CanvasLayer/DebugMenu/VER.text = Global.CURRENTVER
	StarSystem.connect("start_meteors", Callable(self, "start_meteors"))
	$CanvasLayer/Black.show()
	if !Global.gamerules["can_leave_planet"] or ( Global.inTutorial and Global.tutorialStage < 1):
		go_up.hide()
	Global.connect("screenshot", Callable(self, "screenshot"))

func _process(delta):
	if showFPS:
		$CanvasLayer/DebugMenu/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("debug"):
		showFPS = !showFPS
		$CanvasLayer/DebugMenu.visible = showFPS
	$weather.position = $Player/PlayerCamera.global_position - Vector2(142,120)
	#var camera_offset = ($Player/PlayerCamera.get_screen_center_position() - Vector2(lastLightUpdatePos * 8))/8.0
	#if camera_offset.x >= 1 or camera_offset.y >= 1:
		#print("camera_offsetbruh")
	#material.set_shader_parameter("offset_pos",camera_offset)
	#if lastLightImage != lightTexture.get_image():
		#lastLightImage = lightTexture.get_image()
		#print("different")
	#lastLightUpdatePos = $Player/PlayerCamera.previousPos
	#$LightingViewport/SubViewport/LightRect.material.set_shader_parameter("position",lastLightUpdatePos-Vector2i(19,18))
	material.set_shader_parameter("light",$LightRenderViewport.get_texture())

func toggle_wire_visibility(toggle : bool):
	$World/Wires.visible = toggle
	togglePins = toggle
	emit_signal("toggle_pins",toggle)

func weather_event(random = true,time = [200,500], weatherSet = "none",start = true):
	if !is_instance_valid(weatherAnimation):
		await self.ready
	var weatherRandom = RandomNumberGenerator.new()
	weatherRandom.seed = randi()
	if random:
		weatherSet = StarSystem.weatherEvents[worldType][weatherRandom.randi()%StarSystem.weatherEvents[worldType].size()]
	print("starting weather: ",weatherSet)
	currentWeather = weatherSet
	emit_signal("weather_changed",weatherSet)
	weatherAnimation.play(weatherSet + ("" if start else "_no_start"))
	weatherTimer.start(weatherRandom.randf_range(time[0],time[1]))

func set_weather_volume(from : int, to : int) -> void:
	if from == -1:
		from = GlobalAudio.get_volume("environment")
	if to == -1:
		to = GlobalAudio.get_volume("environment")
	$EnvironmentSFX/Rain.volume_db = from
	if to == -2:
		return
	var tween = create_tween().tween_property($EnvironmentSFX/Rain,"volume_db",to,1.5)

func set_weather(random = true,time = [200,500], weatherSet = "none",start = true):
	weatherStartData = {"random":random,"time":time,"set":weatherSet,"start":start}

func new_tutorial_stage():
	match Global.tutorialStage:
		1:
			go_up.show()
			display_text({"text":"Go to space by clicking the 'Go Up' button","text_color":Color.WHITE})

func update_keybinds():
	$CanvasLayer/Hotbar/K/Keybind.text = "?" if Global.settings["keybinds"]["action2"]["event_type"] == "mouse" else char(Global.settings["keybinds"]["action2"]["id"])
	$CanvasLayer/Hotbar/J/Keybind.text = "?" if Global.settings["keybinds"]["action1"]["event_type"] == "mouse" else char(Global.settings["keybinds"]["action1"]["id"])

func _on_World_world_loaded():
	Global.saved_settings.connect(update_keybinds)
	update_keybinds()
	worldType = StarSystem.find_planet_id(Global.currentPlanet).type["type"]
	if weatherStartData.is_empty():
		weather_event(false,[0,500])
	else:
		weather_event(weatherStartData["random"],weatherStartData["time"],weatherStartData["set"],weatherStartData["start"])

func screenshot():
	$CanvasLayer.hide()
	await get_tree().process_frame
	$CanvasLayer.show()

func enable_godmode():
	Global.godmode = true
	inventory.inventory.clear()
	inventory.update_inventory()

func disable_godmode():
	Global.godmode = false
	inventory.inventory.clear()
	inventory.update_inventory()
	inventory.add_to_inventory(4,1)
	inventory.INVENTORY_SIZE = 20
	armor.armor = {"Helmet":{"id":46,"amount":1,"data":{}},"Hat":{},"Chestplate":{"id":47,"amount":1,"data":{}},"Shirt":{},"Leggings":{"id":48,"amount":1,"data":{}},"Pants":{},"Boots":{"id":49,"amount":1,"data":{}},"Shoes":{}}
	armor.emit_signal("updated_armor",armor.armor)

func start_meteors():
	pass

func display_text(textData : Dictionary):
	title.text = textData["text"]
	title.label_settings.font_color = textData["text_color"]
	title.label_settings.outline_color = Color.BLACK if textData["text_color"].get_luminance() > 0.5 else Color.WHITE
	title_timer.stop()
	titleAnim.play("pop up")
	title_timer.start(title.text.length() / 10.0)

func get_item_upgrade_text(data : Dictionary) -> String:
	var upgrades : Dictionary = {}
	for slot in data["upgrades"]:
		var upgrade : String = data["upgrades"][slot]
		if upgrade != "" and world.upgrades.has(upgrade):
			if !upgrades.has(upgrade):
				upgrades[upgrade] = 1
			else:
				upgrades[upgrade] += 1
	var upgradeText : String
	for upgrade : String in upgrades:
		upgradeText += "\n[color=Palegoldenrod]" + world.upgrades[upgrade]["name"] + " " + str(upgrades[upgrade]) + "[/color]"
	return upgradeText

func _on_WeatherTimer_timeout():
	if currentWeather == "none":
		weather_event()
	else:
		weatherAnimation.play(currentWeather + "_stop")
		await weatherAnimation.animation_finished
		weather_event(false)

func _on_title_timer_timeout() -> void:
	titleAnim.play("fade out")

func _on_world_world_loaded() -> void:
	if Global.gamerules["tutorial"]:
		await get_tree().create_timer(1.0).timeout
		if !GlobalGui.completedTutorials.has("tutorial_popup"):
			GlobalGui.display_tutorial("gameplay","tutorial_popup","left",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("movement"):
			GlobalGui.display_tutorial("gameplay","movement","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("hotbar"):
			GlobalGui.display_tutorial("gameplay","hotbar","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("gather_resources"):
			GlobalGui.display_tutorial("gameplay","gather_resources","right")
			await gathered_wood
			GlobalGui.end_current_tutorial()
		if !GlobalGui.completedTutorials.has("gather_resources2"):
			GlobalGui.display_tutorial("gameplay","gather_resources2","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("inventory"):
			GlobalGui.display_tutorial("gameplay","inventory","right")
			await inventory.opened_inventory
			GlobalGui.end_current_tutorial()
		if !GlobalGui.completedTutorials.has("inventory2"):
			GlobalGui.display_tutorial("gameplay","inventory2","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("inventory3"):
			GlobalGui.display_tutorial("gameplay","inventory3","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("inventory4"):
			GlobalGui.display_tutorial("gameplay","inventory4","right",true)
			await GlobalGui.tutorial_closed
		if !GlobalGui.completedTutorials.has("crafting"):
			GlobalGui.display_tutorial("gameplay","crafting","left",true)

func _on_inventory_gained_item(id : int) -> void:
	print("got item")
	if id == 10:
		print("gathered wood")
		gathered_wood.emit()
