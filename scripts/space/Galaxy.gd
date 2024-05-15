extends Node2D

const STAR_ICON = preload("res://assets/space/StarIcon.tscn")
const SECTOR_SIZE = Vector2(568,568)
const GALAXY_SIZE = Vector2(1000,1000)
const SECTOR_STAR_RANGE = [40,60]

var selectedSystem = null
var currentSystem = null
var moving = false

@onready var loading_animation: AnimationPlayer = $CanvasLayer/Loading/LoadingAnimation

func _ready():
	Global.playerData["save_type"] = "galaxy"
	$AnimationPlayer.play("start")
	print(Global.currentSystemId)
	var sectorCoords = system_seed_to_pos(Global.currentSystemId)
	print(sectorCoords)
	update_sectors(sectorCoords)
	if find_system(Global.currentSystem,sectorCoords) != null:
		var system = find_system(Global.currentSystem,sectorCoords)
		currentSystem = system
		$GalaxyView.position = system.global_position
		$CurrentSelector.position = system.global_position
	else:
		$GalaxyView.position = sectorCoords
		$CurrentSelector.position = sectorCoords

func pos_to_seed(pos : Vector2) -> int:
	var strSeed = str(int(pos.y))
	while strSeed.length() < 6:
		strSeed = "0" + strSeed
	strSeed = str(int(pos.x)) + strSeed
	return int(strSeed)

func pos_to_seed_str(pos : Vector2) -> String:
	var y = str(int(pos.y))
	while y.length() < 6:
		y = "0" + y
	var x = str(int(pos.x))
	while x.length() < 6:
		x = "0" + x
	return x + y

func system_seed_to_pos(systemSeed) -> Vector2:
	var seedStr = str(systemSeed)
	var x = seedStr.substr(0,6)
	var y = seedStr.substr(6,6)
	return Vector2(int(x),int(y))

func find_system(systemSeed : int, sector : Vector2) -> Object:
	if $Sectors.has_node(str(sector.x) + "," + str(sector.y)):
		for system in $Sectors.get_node(str(sector.x) + "," + str(sector.y)).get_children():
			if system.systemSeed == systemSeed:
				return system
	return null

func find_system_id(systemId : String, sector : Vector2) -> Object:
	if $Sectors.has_node(str(sector.x) + "," + str(sector.y)):
		for system in $Sectors.get_node(str(sector.x) + "," + str(sector.y)).get_children():
			if system.systemId == systemId:
				return system
	return null

func update_sectors(newMid : Vector2):
	var toLoad = []
	for x in range(newMid.x-SECTOR_SIZE.x,newMid.x+SECTOR_SIZE.x*2,SECTOR_SIZE.x):
		for y in range(newMid.y-SECTOR_SIZE.y,newMid.y+SECTOR_SIZE.y*2,SECTOR_SIZE.y):
			toLoad.append(Vector2(x,y))
	for sector in toLoad:
		if !$Sectors.has_node(str(sector.x) + "," + str(sector.y)):
			load_sector(sector)
	for sector in $Sectors.get_children():
		if !toLoad.has(sector.position) and !sector.get_children().has(selectedSystem):
			sector.queue_free()

func load_sector(coords : Vector2):
	if coords.x >= 0 and coords.x < GALAXY_SIZE.x*SECTOR_SIZE.x and coords.y >= 0 and coords.y < GALAXY_SIZE.y*SECTOR_SIZE.y:
		seed(pos_to_seed(coords))
		var newSector = Node2D.new()
		newSector.name = str(coords.x) + "," + str(coords.y)
		newSector.position = coords
		$Sectors.add_child(newSector)
		var starAmount = int(randf_range(SECTOR_STAR_RANGE[0],SECTOR_STAR_RANGE[1]))
		for i in range(starAmount):
			var newStar = STAR_ICON.instantiate()
			newStar.position = Vector2(randf_range(0,SECTOR_SIZE.x),randf_range(0,SECTOR_SIZE.y))
			newStar.systemSeed = int(pos_to_seed_str(coords) + str(i))
			newStar.systemId = pos_to_seed_str(coords) + str(i)
			var systemData = StarSystem.quick_system_check(newStar.systemSeed)
			newStar.texture_normal = load("res://textures/GUI/space/star_icon_" + systemData["star"] + ".png")
			newSector.add_child(newStar)

func warp(systemId : String, planetId : int):
	moving = true
	var sectorCoords = system_seed_to_pos(systemId)
	load_sector(sectorCoords)
	loading_animation.play("start_loading")
	await loading_animation.animation_finished
	GlobalGui.complete_achievement("Interstellar")
	Global.currentPlanet = planetId
	StarSystem.open_star_system(find_system_id(systemId,sectorCoords).systemSeed,systemId,true)

func system_pressed(system):
	if !moving:
		if system != selectedSystem:
			selectedSystem = system
			$Selected.position = system.global_position
			$SystemInfo.hover(system.global_position,system.systemId)
			$Selected.show()
			$Line.position = $CurrentSelector.position + Vector2(10.5,10.5)
			$Line.rotation_degrees = rad_to_deg($Line.position.angle_to_point($Selected.position + Vector2(10.5,10.5))) - 90
			$Line.size.y = $Line.position.distance_to($Selected.position + Vector2(10.5,10.5))
			$Line.show()
		else:
			$SystemInfo.hide()
			moving = true
			loading_animation.play("start_loading" if currentSystem != system else "open_system")
			await loading_animation.animation_finished
			print("Selected seed: ",selectedSystem.systemSeed)
			GlobalGui.complete_achievement("Interstellar")
			StarSystem.open_star_system(selectedSystem.systemSeed,selectedSystem.systemId,true)

func _on_BookmarkBtn_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$CanvasLayer/Bookmarks.pop_up()
	$CanvasLayer/Bookmarks.visible = button_pressed
