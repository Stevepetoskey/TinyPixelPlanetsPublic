extends StaticBody2D
class_name BaseBlock

@export var id : int = 1
@export var layer : int = 1

var pos : Vector2

@onready var world = $"../.."
@onready var main = $"../../.."

var data = {}

signal destroyed

func ghost_block_block_destroyed():
	world.set_block(pos,layer,0,true)
	destroyed.emit()
