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
var worldType : String

var weatherStartData = {}

var togglePins = false

signal weather_changed
signal toggle_pins
signal output_pressed
signal input_pressed

func _ready():
	StarSystem.connect("start_meteors", Callable(self, "start_meteors"))
	$CanvasLayer/Black.show()
	if !Global.gamerules["can_leave_planet"] or ( Global.inTutorial and Global.tutorialStage < 1):
		go_up.hide()
	Global.connect("screenshot", Callable(self, "screenshot"))

func _process(delta):
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())
	$weather.position = $Player/Camera2D.global_position - Vector2(142,120)

func toggle_wire_visibility(toggle : bool):
	$World/Wires.visible = toggle
	togglePins = toggle
	emit_signal("toggle_pins",toggle)

func weather_event(random = true,time = [200,500], set = "none",start = true):
	if !is_instance_valid(weatherAnimation):
		await self.ready
	var weatherRandom = RandomNumberGenerator.new()
	weatherRandom.seed = randi()
	if random:
		set = StarSystem.weatherEvents[worldType][weatherRandom.randi()%StarSystem.weatherEvents[worldType].size()]
	print("starting weather: ",set)
	currentWeather = set
	emit_signal("weather_changed",set)
	weatherAnimation.play(set + ("" if start else "_no_start"))
	weatherTimer.start(weatherRandom.randf_range(time[0],time[1]))

func set_weather(random = true,time = [200,500], set = "none",start = true):
	weatherStartData = {"random":random,"time":time,"set":set,"start":start}

func new_tutorial_stage():
	match Global.tutorialStage:
		1:
			go_up.show()
			display_text({"text":"Go to space by clicking the 'Go Up' button","text_color":Color.WHITE})

func _on_World_world_loaded():
	$CanvasLayer/Hotbar/K/Keybind.text = "?" if Global.settings["keybinds"]["action2"]["event_type"] == "mouse" else char(Global.settings["keybinds"]["action2"]["id"])
	$CanvasLayer/Hotbar/J/Keybind.text = "?" if Global.settings["keybinds"]["action1"]["event_type"] == "mouse" else char(Global.settings["keybinds"]["action1"]["id"])
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
