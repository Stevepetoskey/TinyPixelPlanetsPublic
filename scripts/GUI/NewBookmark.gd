extends Panel

@onready var icon: TextureRect = $HBoxContainer/Icon
@onready var planet_info: Panel = $"../PlanetInfo"
@onready var title: Label = $Title
@onready var line_edit: LineEdit = $LineEdit

var currentIcon : int

signal new_bookmark

func _ready() -> void:
	for color in $HBoxContainer/GridContainer.get_children():
		color.connect("pressed", Callable(self, "color_pressed").bind(color.modulate))

func pop_up() -> void:
	var foundBookmark = Global.find_bookmark(Global.currentSystemId,planet_info.currentPlanet.id)
	if foundBookmark > -1:
		var currentMark = Global.bookmarks[foundBookmark]
		currentIcon = GlobalData.bookmark_icons.find(currentMark["icon"])
		icon.modulate = currentMark["color"]
		line_edit.text = currentMark["name"]
		title.text = "Edit Marker"
	else:
		currentIcon = randi() % GlobalData.bookmark_icons.size()
		var colorGrid = $HBoxContainer/GridContainer.get_children()
		colorGrid.shuffle()
		icon.modulate = colorGrid[0].modulate
		title.text = "New Marker"
		line_edit.clear()
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ GlobalData.bookmark_icons[currentIcon]+".png")
	show()

func color_pressed(color : Color):
	icon.modulate = color

func _on_Left_pressed() -> void:
	currentIcon -= 1
	if currentIcon < 0:
		currentIcon = GlobalData.bookmark_icons.size()-1
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ GlobalData.bookmark_icons[currentIcon]+".png")

func _on_Right_pressed() -> void:
	currentIcon += 1
	if currentIcon >= GlobalData.bookmark_icons.size():
		currentIcon = 0
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ GlobalData.bookmark_icons[currentIcon]+".png")

func _on_Ok_pressed() -> void:
	var foundBookmark = Global.find_bookmark(Global.currentSystemId,planet_info.currentPlanet.id)
	if foundBookmark > -1:
		var _rmv = Global.bookmarks.pop_at(foundBookmark)
	Global.bookmarks.append({"name":line_edit.text,"icon":GlobalData.bookmark_icons[currentIcon],"color":icon.modulate,"system_id":Global.currentSystemId,"planet_id":planet_info.currentPlanet.id})
	planet_info.pop_up()
	new_bookmark.emit()

func _on_Back_pressed() -> void:
	hide()
