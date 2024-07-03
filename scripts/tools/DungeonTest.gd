extends Node2D

@export var worldSize = Vector2(128,64)

func _ready() -> void:
	var img : Image = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGB8)
	Global.currentSave = "save1"
	var dungeonPieces = Global.load_structures("scorched")
	var dungeonBossRoom = Global.load_structure("boss_scorched.dat")
	var pos = Vector2(64,32)
	var size = dungeonBossRoom["size"]
	var currentId = 0
	var openLinks = {0:[]}
	var dungeon = {0:{"position":pos,"size":dungeonBossRoom["size"]}}
	for link in dungeonBossRoom["structure"]["link_blocks"]:
		openLinks[currentId].append(link)
	#img.fill_rect(Rect2(pos,dungeonBossRoom["size"]),Color.RED)
	for block in dungeonBossRoom["structure"]["blocks"]:
		if block["layer"] == 1:
			print(block["layer"])
			img.set_pixel(block["position"].x + pos.x,block["position"].y + pos.y,Color.RED)
		else:
			pass
			#img.set_pixel(block["position"].x + pos.x,block["position"].y + pos.y,Color.DARK_RED)
	var dungeonSize = randi_range(10,20)
	for room in range(dungeonSize):
		currentId = room + 1
		var selectedLinkRoom : int = openLinks.keys().pick_random()
		while openLinks[selectedLinkRoom].is_empty():
			openLinks.erase(selectedLinkRoom)
			if openLinks.is_empty():
				return
			selectedLinkRoom = openLinks.keys().pick_random()
		var selectedLink : Dictionary = openLinks[selectedLinkRoom].pick_random()
		var possibleRooms : Array = []
		for piece in dungeonPieces:
			for link in piece["structure"]["link_blocks"]:
				var side1 = link["side"]
				var side2 = selectedLink["side"]
				if (side1.x == -side2.x and side1.x != 0) or (side1.y == -side2.y and side1.y != 0):
					possibleRooms.append({"piece":piece,"link":link})
					break
		var roomChosen = false
		while !roomChosen and !possibleRooms.is_empty():
			var chosenRoom = possibleRooms.pick_random()
			var link1Pos = selectedLink["position"] + dungeon[selectedLinkRoom]["position"]
			var link2 = chosenRoom["link"]
			var originPos : Vector2
			if link2["side"].x != 0:
				originPos = Vector2(link1Pos.x+selectedLink["side"].x-(chosenRoom["piece"]["size"].x-1 if selectedLink["side"].x < 0 else 0),-(link2["position"].y-link1Pos.y))
			else:
				originPos = Vector2(-(link2["position"].x-link1Pos.x),link1Pos.y+selectedLink["side"].y-(chosenRoom["piece"]["size"].y-1 if selectedLink["side"].y < 0 else 0))
			var canPlace = true
			for oldRoom in dungeon:
				if Rect2(dungeon[oldRoom]["position"],dungeon[oldRoom]["size"]).intersects(Rect2(originPos,chosenRoom["piece"]["size"])) or !Rect2(Vector2(0,0),worldSize).encloses(Rect2(originPos,chosenRoom["piece"]["size"])):
					canPlace = false
			if canPlace:
				dungeon[currentId] = {"position":originPos,"size":chosenRoom["piece"]["size"]}
				openLinks[selectedLinkRoom].erase(selectedLink)
				if openLinks[selectedLinkRoom].is_empty():
					openLinks.erase(selectedLinkRoom)
				openLinks[currentId] = []
				for link in chosenRoom["piece"]["structure"]["link_blocks"]:
					if link["position"] != link2["position"]:
						openLinks[currentId].append(link)
				for block in chosenRoom["piece"]["structure"]["blocks"]:
					if block["layer"] > 0:
						img.set_pixel(block["position"].x + originPos.x,block["position"].y + originPos.y,Color.WHITE)
					else:
						pass
						#img.set_pixel(block["position"].x+ originPos.x,block["position"].y + originPos.y,Color.LIGHT_GRAY)
				roomChosen = true
			else:
				possibleRooms.erase(chosenRoom)
	$TextureRect.texture = ImageTexture.create_from_image(img)
