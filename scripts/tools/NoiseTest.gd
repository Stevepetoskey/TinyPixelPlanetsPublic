extends Node2D

@export var worldSize = Vector2(128,64)
@export var noise : Noise
@export var noiseScale = 15
@export var worldHeight = 20
@export var asteroids : bool = false
@export var asteroidScale : float = 0.4
@export var waterLevel : int = 50

var world : Dictionary = {}
var img : Image

func _ready() -> void:
	Global.currentSave = "save2"
	img = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGB8)
	for x in range(worldSize.x):
		for y in range(worldSize.y):
			if asteroids:
				img.set_pixel(x,y,Color.WHITE if noise.get_noise_2d(x,y) > asteroidScale else Color.BLACK)
			else:
				var height = (worldSize.y - (int(noise.get_noise_1d(x) * noiseScale) + worldHeight))
				if height > worldSize.y - 4:
					height = worldSize.y - 4
				if y < height and y >= waterLevel:
					set_block(Vector2(x,y),0,Color.BLUE)
					set_block(Vector2(x,y),1,Color.BLUE)
				elif y >= height:
					set_block(Vector2(x,y),0,Color.LIGHT_GRAY)
					set_block(Vector2(x,y),1,Color.WHITE)
	#generate_dungeon("scorched","boss_scorched",randi_range(15,30))
	generate_dungeon("scorched","boss_scorched",randi_range(30,50))
	for layer in range(2):
		for x in range(worldSize.x):
			for y in range(worldSize.y):
				var color = get_block(Vector2(x,y),layer)
				if layer < 1 or color != Color.BLACK:
					img.set_pixel(x,y,color)
	$TextureRect.texture = ImageTexture.create_from_image(img)

func set_block(pos : Vector2, layer : int, color : Color) -> void:
	world[{"pos":pos,"layer":layer}] = color

func get_block(pos : Vector2, layer : int) -> Color:
	if world.has({"pos":pos,"layer":layer}):
		return world[{"pos":pos,"layer":layer}]
	else:
		return Color.BLACK

func generate_dungeon(dungeonGroup : String, startingPiece : String, dungeonSize : int, replaceFloorBlock := [], keepOnGround := false) -> void:
	var dungeonPieces = Global.load_structures(dungeonGroup)
	var dungeonBossRoom = Global.load_structure(startingPiece + ".dat")
	var pos = Vector2(randi_range(0,worldSize.x-12),0)
	var size = dungeonBossRoom["size"]
	pos.y = randi_range((worldSize.y - (int(noise.get_noise_1d(pos.x) * noiseScale) + worldHeight)),worldSize.y-19)
	while !Rect2(Vector2(0,0),worldSize).encloses(Rect2(pos,size)):
		pos.y -= 1
		if pos.y <= 0:
			return
	var currentId = 0
	var openLinks = {0:[]}
	var dungeon = {0:{"position":pos,"size":dungeonBossRoom["size"]}}
	for link in dungeonBossRoom["structure"]["link_blocks"]:
		openLinks[currentId].append(link)
	for block in dungeonBossRoom["structure"]["blocks"]:
		if replaceFloorBlock.is_empty() or !replaceFloorBlock.has(block["id"]):
			match block["id"]:
				187:
					set_block(block["position"] + pos,block["layer"],Color.BLACK)
				#189:
					#var usedGroups = []
					#var chest = []
					#if lootTables.has(block["data"]["group"]):
						#while chest.is_empty():
							#for loot in lootTables[block["data"]["group"]]:
								#if !usedGroups.has(loot["group"]):
									#var amount : int = 0
									#for i in range(loot["amount"]):
										#amount += 1 if randi_range(0,loot["rarity"]) == 0 else 0
									#if amount > 0:
										#if loot["group"] != "none":
											#usedGroups.append(loot["group"])
										#chest.append({"id":loot["id"],"amount":amount})
					#set_block(block["position"] + pos,block["layer"],91,false,chest)
				_:
					set_block(block["position"] + pos,block["layer"],Color.RED if block["layer"] > 0 else Color.MAROON)
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
				if (selectedLink.has("group") and link.has("group") and selectedLink["group"] == link["group"]) or (!selectedLink.has("group") and !link.has("group")):
					print(selectedLink)
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
				if Rect2(dungeon[oldRoom]["position"],dungeon[oldRoom]["size"]).intersects(Rect2(originPos,chosenRoom["piece"]["size"])) or !Rect2(Vector2(0,0),worldSize).encloses(Rect2(originPos,chosenRoom["piece"]["size"])) or (keepOnGround and originPos.y + chosenRoom["piece"]["size"].y < (worldSize.y - (int(noise.get_noise_1d(originPos.x) * noiseScale) + worldHeight))):
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
					if replaceFloorBlock.is_empty() or !replaceFloorBlock.has(block["id"]):
						match block["id"]:
							187:
								set_block(block["position"] + originPos,block["layer"],Color.BLACK)
							#189:
								#var usedGroups = []
								#var chest = []
								#if lootTables.has(block["data"]["group"]):
									#while chest.is_empty():
										#for loot in lootTables[block["data"]["group"]]:
											#if !usedGroups.has(loot["group"]):
												#var amount : int = 0
												#for i in range(loot["amount"]):
													#amount += 1 if randi_range(0,loot["rarity"]) == 0 else 0
												#if amount > 0:
													#if loot["group"] != "none":
														#usedGroups.append(loot["group"])
													#chest.append({"id":loot["id"],"amount":amount})
								#set_block(block["position"] + pos,block["layer"],91,false,chest)
							_:
								set_block(block["position"] + originPos,block["layer"],Color.RED if block["layer"] > 0 else Color.MAROON)
				roomChosen = true
				print("Chose room: ",chosenRoom["piece"]["file_name"])
			else:
				possibleRooms.erase(chosenRoom)
