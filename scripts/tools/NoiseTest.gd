@tool
extends Node2D

@export var worldSize = Vector2(128,64)
@export var noise : Noise
@export var noiseScale = 15
@export var worldHeight = 20
@export var asteroids : bool = false
@export var asteroidScale : float = 0.4
@export var waterLevel : int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()

func _on_timer_timeout() -> void:
	var img : Image = Image.create(worldSize.x,worldSize.y,false,Image.FORMAT_RGB8)
	for x in range(worldSize.x):
		for y in range(worldSize.y):
			if asteroids:
				img.set_pixel(x,y,Color.WHITE if noise.get_noise_2d(x,y) > asteroidScale else Color.BLACK)
			else:
				var height = (worldSize.y - (int(noise.get_noise_1d(x) * noiseScale) + worldHeight))
				if height > worldSize.y - 4:
					height = worldSize.y - 4
				if y < height and y >= waterLevel:
					img.set_pixel(x,y,Color.BLUE)
				elif y >= height:
					img.set_pixel(x,y,Color.WHITE)
				else:
					img.set_pixel(x,y,Color.BLACK)

	$TextureRect.texture = ImageTexture.create_from_image(img)
