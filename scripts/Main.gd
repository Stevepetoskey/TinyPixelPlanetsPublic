extends Node2D

onready var armor = $CanvasLayer/Inventory/Armor
onready var inventory = $CanvasLayer/Inventory
onready var title = $CanvasLayer/Title
onready var titleAnim = $CanvasLayer/Title/AnimationPlayer
onready var weatherAnimation = $weather/WeatherAnimation
onready var weatherTimer = $weather/WeatherTimer

var tutorialStage = 0

var currentWeather = "none"
var worldType : String

func _ready():
	StarSystem.connect("start_meteors",self,"start_meteors")
	$CanvasLayer/Black.show()
	if !Global.gamerules["can_leave_planet"]:
		$CanvasLayer/Hotbar/GoUp.hide()
	Global.connect("screenshot",self,"screenshot")

func _process(delta):
	$CanvasLayer/FPS.text = str(Engine.get_frames_per_second())

func weather_event(random = true,time = [200,500], set = "none"):
	var weatherRandom = RandomNumberGenerator.new()
	weatherRandom.seed = randi()
	if random:
		set = StarSystem.weatherEvents[worldType][weatherRandom.randi()%StarSystem.weatherEvents[worldType].size()]
	print("starting weather: ",set)
	currentWeather = set
	weatherAnimation.play(set)
	weatherTimer.start(weatherRandom.randf_range(time[0],time[1]))

func _on_World_world_loaded():
	worldType = StarSystem.find_planet_id(Global.currentPlanet).type["type"]
	GlobalAudio.change_mode("game")
	yield(get_tree(),"idle_frame")
	if Global.inTutorial:
		title.text = "Move left/right with A/D, or with arrow keys"
		titleAnim.play("pop up")
		yield(get_tree().create_timer(5),"timeout")
		if tutorialStage == 0:
			titleAnim.play("fade out")
			yield(titleAnim,"animation_finished")
			title.text = "Jump with the SPACE key or up arrow"
			titleAnim.play("pop up")
			yield(get_tree().create_timer(5),"timeout")
			if tutorialStage == 0:
				titleAnim.play("fade out")
	else:
		$World/TutorialParts/Platforms/CollisionShape2D.shape = null
		$World/TutorialParts/Sprint/CollisionShape2D.shape = null
		$World/TutorialParts/Chest/CollisionShape2D.shape = null
		$World/TutorialParts/Mine/CollisionShape2D.shape = null
	weather_event(false,[0,500])

func screenshot():
	$CanvasLayer.hide()
	yield(get_tree(),"idle_frame")
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
	armor.armor = {"Helmet":{"id":46,"amount":1},"Hat":{},"Chestplate":{"id":47,"amount":1},"Shirt":{},"Leggings":{"id":48,"amount":1},"Pants":{},"Boots":{"id":49,"amount":1},"Shoes":{}}
	armor.emit_signal("updated_armor",armor.armor)

func start_meteors():
	pass

func _on_Area2D_body_entered(body):
	tutorialStage = 1
	title.text = "You can jump through platforms, to go down press the S key or down arrow"
	titleAnim.play("pop up")

func _on_Area2D_body_exited(body):
	titleAnim.play("fade out")

func _on_Sprint_body_entered(body):
	title.text = "To sprint hold down the SHIFT key"
	titleAnim.play("pop up")

func _on_Sprint_body_exited(body):
	titleAnim.play("fade out")

func _on_Chest_body_entered(body):
	tutorialStage = 2
	title.text = "To interact with blocks that make your cursor blue, left click"
	titleAnim.play("pop up")
	yield(get_tree().create_timer(5),"timeout")
	if tutorialStage == 2:
		titleAnim.play("fade out")
		yield(titleAnim,"animation_finished")
		title.text = "Press 'E' or click on the hotbar slot to open your inventory" 
		titleAnim.play("pop up")
		yield(get_tree().create_timer(5),"timeout")
		if tutorialStage == 2:
			titleAnim.play("fade out")

func _on_Mine_body_entered(body):
	tutorialStage = 3
	title.text = "To use items in the dark grey slot, left click. Right click for light grey slot"
	titleAnim.play("pop up")
	yield(get_tree().create_timer(7),"timeout")
	if tutorialStage == 3:
		titleAnim.play("fade out")
		yield(titleAnim,"animation_finished")
		title.text = "If you press J or K over a slot in your inventory (not the hotbar), it will be added to the J or K slot" 
		titleAnim.play("pop up")
		yield(get_tree().create_timer(10),"timeout")
		if tutorialStage == 3:
			titleAnim.play("fade out")

func _on_WeatherTimer_timeout():
	if currentWeather == "none":
		weather_event()
	else:
		weatherAnimation.play(currentWeather + "_stop")
		yield(weatherAnimation,"animation_finished")
		weather_event(false)
