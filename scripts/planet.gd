extends Sprite2D

const MARKER_CUTOFF : int = 3

var planetRef : Object

var bookmarkerData : Dictionary
var bookmarkFollow : bool = true

@onready var main = get_node("../..")
@onready var viewPort = $SubViewportContainer
@onready var marker: Sprite2D = $Marker
@onready var ship_camera: Camera2D = $"../../ship/Camera2D"

func _ready():
	marker.hide()
	$Area2D/CollisionShape2D.shape.radius = StarSystem.sizeData[planetRef.type["size"]]["radius"]
	viewPort.material.set_shader_parameter("planet",planetRef.type["texture"])
	match planetRef.type["size"]:
		0:
			viewPort.size = Vector2(14,14)
			viewPort.position = Vector2(-7,-7)
		1:
			viewPort.size = Vector2(28,28)
			viewPort.position = Vector2(-14,-14)
		2:
			viewPort.size = Vector2(56,56)
			viewPort.position = Vector2(-28,-28)

func _process(delta):
	position = planetRef.position
	$SubViewportContainer/SubViewport/Node3D.angle = planetRef.shadeAngle
	if bookmarkFollow:
		var off : Vector2 = Vector2(clampf(global_position.x - ship_camera.global_position.x,-get_viewport_rect().size.x / 2.0 + MARKER_CUTOFF,get_viewport_rect().size.x / 2.0 - MARKER_CUTOFF),clampf(global_position.y - ship_camera.global_position.y,-get_viewport_rect().size.y / 2.0 + MARKER_CUTOFF,get_viewport_rect().size.y / 2.0 - MARKER_CUTOFF))
		#Vector2(sign(global_position.x - ship_camera.global_position.x) * (get_viewport_rect().size.x / 2.0),sign(global_position.y - ship_camera.global_position.y) * (get_viewport_rect().size.y / 2.0))
		marker.global_position = ship_camera.global_position + off
		marker.rotation = ship_camera.global_position.angle_to_point(global_position) - deg_to_rad(90)

func update_bookmark(bookmark : Dictionary) -> void:
	bookmarkerData = bookmark
	if !bookmarkerData.is_empty():
		marker.modulate = bookmarkerData["color"]
		marker.texture = load("res://textures/GUI/space/bookmark_icons/"+ bookmarkerData["icon"]+".png")
		marker.position = Vector2(0,viewPort.position.y - 2)
		marker.show()

func _on_Area2D_body_entered(body):
	if !["gas1","gas2","gas3"].has(planetRef.type["type"]):
		main.planet_entered(self)

func _on_discover_body_entered(body: Node2D) -> void:
	main.discover_planet(planetRef.id)

func _on_marker_visible_screen_exited() -> void:
	bookmarkFollow = true

func _on_marker_visible_screen_entered() -> void:
	bookmarkFollow = false
	marker.rotation = 0
	marker.position = Vector2(0,viewPort.position.y - 2)
