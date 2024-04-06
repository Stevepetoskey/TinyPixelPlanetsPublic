extends Panel

const BOOKMARK = preload("res://assets/GUI/Bookmark.tscn")

onready var bookmark_container: VBoxContainer = $ScrollContainer/BookmarkContainer
onready var galaxy: Node2D = $"../.."

func pop_up():
	if bookmark_container.get_child_count() <= 0:
		for bookmark in Global.bookmarks:
			var bm = BOOKMARK.instance()
			print(bookmark["icon"])
			bm.get_node("Bookmark").texture = load("res://textures/GUI/space/bookmark_icons/" + bookmark["icon"] +".png")
			bm.get_node("Bookmark").modulate = bookmark["color"]
			bm.get_node("Title").text = bookmark["name"]
			bm.id = Global.bookmarks.find(bookmark)
			bookmark_container.add_child(bm)
	show()

func bookmark_pressed(id : int):
	galaxy.warp(Global.bookmarks[id]["system_id"],Global.bookmarks[id]["planet_id"])
