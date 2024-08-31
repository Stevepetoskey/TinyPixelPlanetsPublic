extends Panel

var bookmarkTextures = {false:preload("res://textures/GUI/space/bookmark_btn.png"),true:preload("res://textures/GUI/space/buttons/bookmarked_btn.png")}

@onready var rename_planet: Panel = $"../RenamePlanet"
@onready var new_bookmark: Panel = $"../NewBookmark"
@onready var planet_name: Label = $Top/ScrollContainer/PlanetName
@onready var bookmark_btn: TextureButton = $Top/Bookmark
@onready var planet_select: Node2D = $"../.."
@onready var danger_lbl: RichTextLabel = $ScrollContainer/VBoxContainer/DangerLbl

var currentPlanet = null

func pop_up(planet : Area2D = null):
	planet_select.pause = true
	rename_planet.hide()
	new_bookmark.hide()
	var planetRef = currentPlanet if planet == null else planet.get_parent().planetRef
	currentPlanet = planetRef
	planet_name.text = planetRef.pName
	bookmark_btn.texture_normal = bookmarkTextures[Global.find_bookmark(Global.currentSystemId,planetRef.id) > -1]
	$ScrollContainer/VBoxContainer/Type.text = "Type: " + StarSystem.typeNames[planetRef.type["type"]]
	$ScrollContainer/VBoxContainer/Size.text = "Size: " + StarSystem.sizeNames[planetRef.type["size"]]
	var text = "Danger: "
	match planetRef.type["type"]:
		"scorched":
			text += "[color=firebrick]Extreme heat[/color]"
		"frigid":
			text += "[color=skyblue]Extreme cold[/color]"
		_:
			text += "[color=lawngreen]None[/color]"
	danger_lbl.text = text
	for event in $ScrollContainer/VBoxContainer/WeatherEvents.get_children():
		event.visible = StarSystem.weatherEvents[planetRef.type["type"]].has(event.name)
	show()

func _on_Exit_pressed() -> void:
	planet_select.pause = false
	hide()
	rename_planet.hide()
	new_bookmark.hide()

func _on_Edit_pressed() -> void:
	rename_planet.show()
	$"../RenamePlanet/LineEdit".text = currentPlanet.pName

func _on_Ok_pressed() -> void:
	if currentPlanet != null:
		currentPlanet.pName = $"../RenamePlanet/LineEdit".text
		Global.save_system()
		$"../Nav".update_nav()
		pop_up()

func _on_Bookmark_pressed() -> void:
	new_bookmark.pop_up()

func _on_Back_pressed() -> void:
	rename_planet.hide()
