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

const lightColorDictNoAtmo = {
	SUNSET = Color(0.75,0.75,0.75),
	DAY = Color.WHITE,
	SUNRISE = Color(0.75,0.75,0.75),
	NIGHT = Color(0.5,0.5,0.5)
}

var lightColorDict = {}

@export var defualtColor = Color.WHITE
@export var nightColor = Color(0.43,0.39,0.49)

@onready var sky = get_node("../ParallaxBackground/SkyLayer/sky")

var oldTime = -1.0
var active = false

func _process(delta):
	if active:
		var time = get_node("../ParallaxBackground2/Sky").get_day_light()
		var TOD = get_node("../ParallaxBackground2/Sky").get_day_type()
		if time != oldTime:
			get_node("../ParallaxBackground2/Sky").set_atmosphere(time*1)
			if time == 1.0:
				change_sounds(-5,0,-1000)
				Global.lightColor = lightColorDict.DAY
				sky.modulate = skyColorDict.DAY
				sky.show()
			elif time == -1.0:
				change_sounds(-1000,-1000,-15)
				Global.lightColor = lightColorDict.NIGHT
				sky.modulate = skyColorDict.NIGHT * Color(1,1,1,0)
				sky.hide()
			elif TOD =="sunset":
				sky.show()
				change_sounds(lerp(-5,-35,1-time),lerp(0,-35,1-time),lerp(-50,-15,1-time))
				if time >= 0.5:
					sky.modulate = lerp(skyColorDict.DAY,skyColorDict.SUNSET,1-(time-0.5)*2.0)
					Global.lightColor = lerp(lightColorDict.DAY,lightColorDict.SUNSET,1-(time-0.5)*2.0)
				else:
					sky.modulate = lerp(skyColorDict.SUNSET,skyColorDict.NIGHT * Color(1,1,1,0),1-(time*2.0))
					Global.lightColor = lerp(lightColorDict.SUNSET,lightColorDict.NIGHT,1-(time*2.0))
			else:
				change_sounds(lerp(-5,-35,1-time),lerp(0,-35,1-time),lerp(-50,-15,1-time))
				sky.show()
				if time <= 0.5:
					Global.lightColor = lerp(lightColorDict.NIGHT,lightColorDict.SUNRISE,time*2.0)
					sky.modulate = lerp(skyColorDict.NIGHT * Color(1,1,1,0),skyColorDict.SUNRISE,time*2.0)
				else:
					Global.lightColor = lerp(lightColorDict.SUNRISE,lightColorDict.DAY,(time-.5)*2.0)
					sky.modulate = lerp(skyColorDict.SUNRISE,skyColorDict.DAY,(time-.5)*2.0)
			
			$back.modulate = Global.lightColor
			$front.modulate = Global.lightColor
			$"../ParallaxBackground2/StormLayer".modulate = Global.lightColor
			$"../../weather/Rain".modulate = Global.lightColor
			$"../../weather/Snow".modulate = Global.lightColor
			get_node("../../World/blocks").modulate = Global.lightColor
			get_node("../../Player").modulate = Global.lightColor
			get_node("../../Entities").modulate = Global.lightColor
		oldTime = time

func change_sounds(volume1 : int,volume2 = -1000, volume3 = -1000) -> void:
	match StarSystem.find_planet_id(Global.currentPlanet).type["type"]:
		"terra":
			if volume1 == -1000:
				get_node("../../sfx/forest").stop()
			else:
				if !get_node("../../sfx/forest").playing:
					get_node("../../sfx/forest").play()
				get_node("../../sfx/forest").volume_db = volume1
			if volume2 == -1000:
				get_node("../../sfx/wind").stop()
			else:
				if !get_node("../../sfx/wind").playing:
					get_node("../../sfx/wind").play()
				get_node("../../sfx/wind").volume_db = volume2
			if volume3 == -1000:
				get_node("../../sfx/crickets").stop()
			else:
				if !get_node("../../sfx/crickets").playing:
					get_node("../../sfx/crickets").play()
				get_node("../../sfx/crickets").volume_db = volume3
		"snow_terra","snow":
			if volume1 == -1000:
				get_node("../../sfx/winterWind").stop()
			else:
				if !get_node("../../sfx/winterWind").playing:
					get_node("../../sfx/winterWind").play()
				get_node("../../sfx/winterWind").volume_db = volume1
		"ocean":
			if volume1 == -1000:
				$"../../sfx/Ocean".stop()
			else:
				if !$"../../sfx/Ocean".playing:
					$"../../sfx/Ocean".play()
				$"../../sfx/Ocean".volume_db = volume1

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
			get_node("../../sfx/crickets").play()
			get_node("../../sfx/forest").play()
			get_node("../../sfx/wind").play()
		"snow_terra","snow":
			get_node("../../sfx/winterWind").play()
		"ocean":
			$"../../sfx/Ocean".play()
