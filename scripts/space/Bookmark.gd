extends Button

export var id := 0

onready var bookmarks: Panel = $"../../.."

func _pressed() -> void:
	bookmarks.bookmark_pressed(id)
