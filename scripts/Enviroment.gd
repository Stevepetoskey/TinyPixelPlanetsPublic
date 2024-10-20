extends ParallaxBackground

const skyColorDict = {
	SUNSET = Color("ff462d"),
	DAY = Color.WHITE,
	SUNRISE = Color("ffd190"),
	NIGHT = Color("3d1b63")
}

const lightColorDictAtmo = {
	SUNSET = Color("F6635C"),
	DAY = Color.WHITE,
	SUNRISE = Color("ffa948"),
	NIGHT = Color("6d5e79")
}

const lightIntensityDict = {
	SUNSET = 7,
	DAY = 12,
	SUNRISE = 7,
	NIGHT = 3
}

const lightColorDictNoAtmo = {
	SUNSET = Color(0.75,0.75,0.75),
	DAY = Color.WHITE,
	SUNRISE = Color(0.75,0.75,0.75),
	NIGHT = Color(0.5,0.5,0.5)
}

var lightColorDict = {}

@export var defualtColor = Color.WHITE
@export var nightColor = Color(0.43,0.39,0.49)

@onready var skyTexture = get_node("../ParallaxBackground/SkyLayer/sky")
@onready var sky: Node2D = $"../ParallaxBackground2/Sky"
var oldTime = -9999.0
var active = false

@onready var daySound: AudioStreamPlayer = $"../../sfx/DaySound"
@onready var nightSound: AudioStreamPlayer = $"../../sfx/NightSound"
@onready var constantSound: AudioStreamPlayer = $"../../sfx/ConstantSound"

func _process(delta):
	if active:
		var time = sky.get_day_light()
		var TOD = sky.get_day_type()
		match TOD:
			"day":
				set_sounds(true,false)
				daySound.volume_db = -10
				Global.lightColor = lightColorDict.DAY
				Global.lightIntensity = lightIntensityDict.DAY
				skyTexture.modulate = skyColorDict.DAY
				skyTexture.show()
			"night":
				set_sounds(false,true)
				nightSound.volume_db = -10
				Global.lightColor = lightColorDict.NIGHT
				Global.lightIntensity = lightIntensityDict.NIGHT
				skyTexture.modulate = skyColorDict.NIGHT * Color(1,1,1,0)
				skyTexture.hide()
			"sunset":
				set_sounds(true,true)
				daySound.volume_db = lerp(-80,-10,time)
				nightSound.volume_db = lerp(-10,-80,time)
				skyTexture.show()
				if time >= 0.5:
					skyTexture.modulate = lerp(skyColorDict.DAY,skyColorDict.SUNSET,1-(time-0.5)*2.0)
					Global.lightColor = lerp(lightColorDict.DAY,lightColorDict.SUNSET,1-(time-0.5)*2.0)
					Global.lightIntensity = lerp(lightIntensityDict.DAY,lightIntensityDict.SUNSET,1-(time-0.5)*2.0)
				else:
					skyTexture.modulate = lerp(skyColorDict.SUNSET,skyColorDict.NIGHT * Color(1,1,1,0),1-(time*2.0))
					Global.lightColor = lerp(lightColorDict.SUNSET,lightColorDict.NIGHT,1-(time*2.0))
					Global.lightIntensity = lerp(lightIntensityDict.SUNSET,lightIntensityDict.NIGHT,1-(time-0.5)*2.0)
			"sunrise":
				set_sounds(true,true)
				daySound.volume_db = lerp(-80,-10,time)
				nightSound.volume_db = lerp(-10,-80,time)
				skyTexture.show()
				if time <= 0.5:
					Global.lightColor = lerp(lightColorDict.NIGHT,lightColorDict.SUNRISE,time*2.0)
					skyTexture.modulate = lerp(skyColorDict.NIGHT * Color(1,1,1,0),skyColorDict.SUNRISE,time*2.0)
					Global.lightIntensity = lerp(lightIntensityDict.NIGHT,lightIntensityDict.SUNRISE,1-(time-0.5)*2.0)
				else:
					Global.lightColor = lerp(lightColorDict.SUNRISE,lightColorDict.DAY,(time-.5)*2.0)
					Global.lightIntensity = lerp(lightIntensityDict.SUNRISE,lightIntensityDict.DAY,1-(time-0.5)*2.0)
					skyTexture.modulate = lerp(skyColorDict.SUNRISE,skyColorDict.DAY,(time-.5)*2.0)
		$back.modulate = Global.lightColor
		$front.modulate = Global.lightColor
		$"../ParallaxBackground2/StormLayer".modulate = Global.lightColor
		#$"../../weather/Rain".modulate = Global.lightColor
		#$"../../weather/Snow".modulate = Global.lightColor
		#get_node("../../World/blocks").modulate = Global.lightColor
		#get_node("../../Player").modulate = Global.lightColor
		#get_node("../../Entities").modulate = Global.lightColor
		$"../../LightingViewport/SubViewport/LightRect".material.set_shader_parameter("natural_light_color",Vector3(Global.lightColor.r,Global.lightColor.g,Global.lightColor.b))
		$"../../LightingViewport/SubViewport/LightRect".material.set_shader_parameter("natural_light_intensity",Global.lightIntensity)
		oldTime = time

func set_sounds(day : bool, night : bool) -> void:
	if day and !daySound.playing:
		daySound.play()
	elif !day:
		daySound.stop()
	if night and !nightSound.playing:
		nightSound.play()
	elif !night:
		nightSound.stop()

func set_background(type : String):
	match type:
		"asteroids":
			$back/Sprite2D.hide()
			$front/Sprite2D.hide()
			$front/Underground.hide()
		_:
			$back/Sprite2D.show()
			$front/Sprite2D.show()
			$back/Sprite2D.texture = load("res://textures/enviroment/backgrounds/"+type+"_back.png")
			$front/Sprite2D.texture = load("res://textures/enviroment/backgrounds/"+type+"_front.png")
			$front/Underground.texture = load("res://textures/enviroment/backgrounds/"+type+"_underground.png")
			match type:
				"ocean":
					$back.motion_scale.y = 0.9
					$front.motion_scale.y = 0.95
					$back.motion_offset.y += 120
					$front.motion_offset.y += 116
				"grassland":
					$front.motion_offset.y += 20
					$back.motion_offset.y += 20

func _on_World_world_loaded():
	if StarSystem.find_planet_id(Global.currentPlanet).hasAtmosphere:
		lightColorDict = lightColorDictAtmo
	else:
		lightColorDict = lightColorDictNoAtmo
	active = true
	match StarSystem.find_planet_id(Global.currentPlanet).type["type"]:
		"terra":
			daySound.stream = load("res://Audio/sfx/Ambience/mixkit-spring-forest-with-woodpeckers-1217.wav")
			nightSound.stream = load("res://Audio/sfx/Ambience/mixkit-summer-crickets-loop-1788.ogg")
			constantSound.stream = load("res://Audio/sfx/Ambience/mixkit-wind-in-the-forest-loop-1233.ogg")
			constantSound.volume_db = -15
			constantSound.play()
		"snow_terra","snow":
			daySound.stream = load("res://Audio/sfx/Ambience/mixkit-blizzard-cold-winds-1153.ogg")
		"ocean":
			daySound.stream = load("res://Audio/sfx/Ambience/mixkit-sea-waves-loop-1196.wav")
