extends ParallaxBackground

const skyColorDict = {
	SUNSET = Color("ff462d"),
	DAY = Color.white,
	SUNRISE = Color("ffd190"),
	NIGHT = Color("3d1b63")
}

const lightColorDictAtmo = {
	SUNSET = Color("F6635C"),
	DAY = Color.white,
	SUNRISE = Color("ffa948"),
	NIGHT = Color("6d5e79")
}

const lightColorDictNoAtmo = {
	SUNSET = Color(0.75,0.75,0.75),
	DAY = Color.white,
	SUNRISE = Color(0.75,0.75,0.75),
	NIGHT = Color(0.5,0.5,0.5)
}

var lightColorDict = {}

export var defualtColor = Color.white
export var nightColor = Color(0.43,0.39,0.49)

onready var sky = get_node("../ParallaxBackground/SkyLayer/sky")

var backTextures = {"terra":preload("res://textures/enviroment/backgrounds/terra_back.png"),
	"stone":preload("res://textures/enviroment/backgrounds/stone_back.png"),
	"snow":preload("res://textures/enviroment/backgrounds/snow_back.png"),
	"snow_terra":preload("res://textures/enviroment/backgrounds/snow_back.png"),
	"mud":preload("res://textures/enviroment/backgrounds/mud_back.png"),
	"desert":preload("res://textures/enviroment/backgrounds/desert_back.png"),
	"exotic":preload("res://textures/enviroment/backgrounds/exotic_back.png"),
	"ocean":preload("res://textures/enviroment/backgrounds/ocean_back.png")
}
var frontTextures = {"terra":preload("res://textures/enviroment/backgrounds/terra_front.png"),
	"stone":preload("res://textures/enviroment/backgrounds/stone_front.png"),
	"snow":preload("res://textures/enviroment/backgrounds/snow_front.png"),
	"snow_terra":preload("res://textures/enviroment/backgrounds/snow_terra_front.png"),
	"mud":preload("res://textures/enviroment/backgrounds/mud_front.png"),
	"desert":preload("res://textures/enviroment/backgrounds/desert_front.png"),
	"exotic":preload("res://textures/enviroment/backgrounds/exotic_front.png"),
	"ocean":preload("res://textures/enviroment/backgrounds/ocean_front.png")
}

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

func set_background(type : String):
	match type:
		"asteroids":
			$back/Sprite.hide()
			$front/Sprite.hide()
		_:
			$back/Sprite.show()
			$front/Sprite.show()
			$back/Sprite.texture = backTextures[type]
			$front/Sprite.texture = frontTextures[type]
			if type == "ocean":
				$back.motion_scale.y = 0.9
				$front.motion_scale.y = 0.95
				$back.motion_offset.y += 155
				$front.motion_offset.y += 165

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
