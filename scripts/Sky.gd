extends Node2D

const SKY_RADIUS = 75
#const RAISED = 16
const PLANET = preload("res://assets/SkyBody.tscn")

func init_sky():
	var mainPlanet = StarSystem.find_planet_id(Global.currentPlanet)
	var star = PLANET.instantiate()
	star.isStar = true
	star.name = "star"
	star.mainPlanet = mainPlanet
	add_child(star)
	for planet in StarSystem.get_system_bodies():
		if planet != mainPlanet:
			var skyBody = PLANET.instantiate()
			skyBody.planetRef = planet
			skyBody.mainPlanet = mainPlanet
			add_child(skyBody)

func get_day_time() -> float: #0 is sunrise, 270 is noon
	if has_node("star"):
		return reset_angle(rad_to_deg(get_node("star").rot))
	return -1.0

func get_day_light() -> float:
	var time = get_day_time()
	if time < 340 and time > 200:
		return 1.0
	elif time > 10 and time < 170:
		return 0.0
	elif time >= 170 and time <= 200:
		return lerp(0.0,1.0,(time-170)/30.0)
	else:
		return lerp(1.0,0.0,(reset_angle(time+20))/30.0)

func get_day_type() -> String:
	var time = get_day_time()
	if time < 340 and time > 200:
		return "day"
	elif time > 10 and time < 170:
		return "night"
	elif time >= 170 and time <= 200:
		return "sunset"
	else:
		return "sunrise"

func reset_angle(angle : float) -> float:
	while angle < 0:
		angle += 360
	while angle >= 360:
		angle -= 360
	return angle

func set_atmosphere(value : float) -> void:
	if has_node("star"):
		get_node("star").material.set_shader_parameter("atmoPressure",value)
