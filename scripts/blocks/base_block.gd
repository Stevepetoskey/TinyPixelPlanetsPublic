extends StaticBody2D
class_name BaseBlock

@export var id : int = 1
@export var layer : int = 1

var pos : Vector2
var atlas_mode : bool = false
var solid : bool = false
var transparent : bool = false

@onready var world = $"../.."
@onready var main = $"../../.."

var data = {}

signal destroyed

func ghost_block_block_destroyed():
	world.set_block(pos,layer,0,true)
	destroyed.emit()

func get_atlas_pos() -> Vector2:
	var connectionsByte : String = "000000000"
	var specialConnections : bool = GlobalData.blockData[id].has("atlas_connection")
	for x : int in [-1,1]:
		for y : int in [-1,1]:
			#Corner blocks are only counted if both adjacent blocks are connected, thats why this is done in a weird way
			var cornerBlock : BaseBlock = world.get_block(pos + Vector2(x,y),layer)
			var adjBlock1 : BaseBlock =  world.get_block(pos + Vector2(0,y),layer)
			var adjBlock2 : BaseBlock =  world.get_block(pos + Vector2(x,0),layer)
			var adjBlock1Valid : bool = is_instance_valid(adjBlock1) and (!specialConnections or GlobalData.blockData[id]["atlas_connection"].has(adjBlock1.id)) and adjBlock1.atlas_mode
			var adjBlock2Valid : bool = is_instance_valid(adjBlock2) and (!specialConnections or GlobalData.blockData[id]["atlas_connection"].has(adjBlock2.id)) and adjBlock2.atlas_mode
			if id == 10 and is_instance_valid(adjBlock1) and adjBlock1.id == 10:
				print("guh?")
				print(typeof(GlobalData.blockData[id]["atlas_connection"][0]))
				print(specialConnections,GlobalData.blockData[id]["atlas_connection"].has(adjBlock1.id),adjBlock1.atlas_mode)
			if adjBlock1Valid:
				connectionsByte[1 + (y + 1) * 3] = "1"
			if adjBlock2Valid:
				connectionsByte[x + 4] = "1"
			if adjBlock1Valid and adjBlock2Valid and is_instance_valid(cornerBlock) and cornerBlock.atlas_mode:
				connectionsByte[x + 1 + (y + 1) * 3] = "1"
	var atlas_pos : Vector2 = Vector2(0,24)
	if GlobalData.atlas_connections.has(connectionsByte):
		atlas_pos = Vector2(GlobalData.atlas_connections[connectionsByte])
		solid = Vector2i(atlas_pos) == Vector2i(72,16)
	return atlas_pos
