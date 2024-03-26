extends StaticBody2D
class_name BaseBlock

export var id : int = 1
export var layer : int = 1

var pos : Vector2

onready var world = $"../.."
onready var main = $"../../.."

var data = {}
