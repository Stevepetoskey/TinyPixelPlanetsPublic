extends Panel

@onready var icon: TextureRect = $HBoxContainer/Icon
@onready var planet_info: Panel = $"../PlanetInfo"
@onready var title: Label = $Title
@onready var line_edit: LineEdit = $LineEdit

var icons = ["circle","square","star","triangle","house","pickaxe"]
var currentIcon : int

func _ready() -> void:
	for color in $HBoxContainer/GridContainer.get_children():
		color.connect("pressed", Callable(self, "color_pressed").bind(color.modulate))

func pop_up() -> void:
	var foundBookmark = Global.find_bookmark(Global.currentSystemId,planet_info.currentPlanet.id)
	if foundBookmark > -1:
		var currentMark = Global.bookmarks[foundBookmark]
		currentIcon = icons.find(currentMark["icon"])
		icon.modulate = currentMark["color"]
		line_edit.text = currentMark["name"]
		title.text = "Edit Marker"
	else:
		currentIcon = randi() % icons.size()
		var colorGrid = $HBoxContainer/GridContainer.get_children()
		colorGrid.shuffle()
		icon.modulate = colorGrid[0].modulate
		title.text = "New Marker"
		line_edit.clear()
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ icons[currentIcon]+".png")
	show()

func color_pressed(color : Color):
	icon.modulate = color

func _on_Left_pressed() -> void:
	currentIcon -= 1
	if currentIcon < 0:
		currentIcon = icons.size()-1
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ icons[currentIcon]+".png")

func _on_Right_pressed() -> void:
	currentIcon += 1
	if currentIcon >= icons.size():
		currentIcon = 0
	icon.texture = load("res://textures/GUI/space/bookmark_icons/"+ icons[currentIcon]+".png")

func _on_Ok_pressed() -> void:
	print(icons[currentIcon])
	var foundBookmark = Global.find_bookmark(Global.currentSystemId,planet_info.currentPlanet.id)
	if foundBookmark > -1:
		var _rmv = Global.bookmarks.pop_at(foundBookmark)
	Global.bookmarks.append({"name":line_edit.text,"icon":icons[currentIcon],"color":icon.modulate,"system_id":Global.currentSystemId,"planet_id":planet_info.currentPlanet.id})
	planet_info.pop_up()

func _on_Back_pressed() -> void:
	hide()
