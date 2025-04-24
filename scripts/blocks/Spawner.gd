extends BaseBlock

const SHADE_TEX = preload("res://textures/blocks/shade.png")

var fallPos : Vector2
var spawning : bool = false

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var rain_col: LightOccluder2D = $RainCol
@onready var mainCol: CollisionShape2D = $CollisionShape2D
@onready var texture: Sprite2D = $Sprite2D
@onready var fire_particles: CPUParticles2D = $FireParticles
@onready var player: CharacterBody2D = $"../../../Player"
@onready var spawn_timer: Timer = $SpawnTimer
@onready var entities: Node2D = $"../../../Entities"

func _ready():
	z_index = layer
	if layer < 1:
		modulate = Color(0.68,0.68,0.68)
		mainCol.disabled = true
		rain_col.queue_free()
		z_index -= 1
	pos = position / world.BLOCK_SIZE
	world.connect("update_blocks", Callable(self, "on_update"))
	world.connect("world_loaded", Callable(self, "world_loaded"))

func _process(delta: float) -> void:
	if position.distance_to(player.position) < 96:
		if !spawning:
			spawning = true
			fire_particles.emitting = true
			spawn_timer.start()
	else:
		spawning = false
		fire_particles.emitting = false
		spawn_timer.stop()

func spawn():
	randomize()
	var summon : String
	match id:
		190:
			summon = "scorched_guard"
			print("spawning")
		206:
			summon = "frigid_spike"
	var hAmount = 0
	for child in entities.get_node("Hold").get_children():
		if child.is_in_group("enemy") and child.type == summon and Rect2(position - Vector2(48,48),Vector2(96,96)).has_point(child.position):
			hAmount += 1
	if hAmount < 5:
		var amount = randi_range(0,3)
		var possiblePos = []
		for x in range(pos.x -6,pos.x+6):
			for y in range(pos.y-6,pos.y+6):
				if GlobalData.blockData[world.get_block_id(Vector2(x,y+2),layer)]["can_collide"] and !GlobalData.blockData[world.get_block_id(Vector2(x,y+1),1)]["can_collide"] and !GlobalData.blockData[world.get_block_id(Vector2(x,y),1)]["can_collide"] and !GlobalData.blockData[world.get_block_id(Vector2(x,y-1),1)]["can_collide"]:
					possiblePos.append(Vector2(x,y))
		for i in range(amount):
			if !possiblePos.is_empty() and hAmount < 5:
				var pos2 = possiblePos.pick_random()
				entities.summon_entity(summon,pos2*8)
				possiblePos.erase(pos2)
				hAmount += 1

func world_loaded():
	on_update()

func on_update():
	if layer < 1:
		if GlobalData.blockData[world.get_block_id(pos,1)]["transparent"] and ([0,10,77].has(world.get_block_id(pos,1)) or id != world.get_block_id(pos,1)):
			show()
		else:
			hide()
		if world.worldLoaded and visible_on_screen_notifier_2d.is_on_screen():
			for x in range(-1,2):
				for y in range(-1,2):
					if abs(x) != abs(y):
						if ![0,6,7,9,30].has(world.get_block_id(pos + Vector2(x,y),1)) and !$shade.has_node(str(x) + str(y)):
							var shade = Sprite2D.new()
							shade.texture = SHADE_TEX
							shade.name = str(x) + str(y)
							shade.rotation = deg_to_rad({Vector2(0,1):0,Vector2(-1,0):90,Vector2(0,-1):180,Vector2(1,0):270}[Vector2(x,y)])
							$shade.add_child(shade)
						elif world.get_block_id(pos + Vector2(x,y),1) == 0 and $shade.has_node(str(x) + str(y)):
							$shade.get_node(str(x) + str(y)).queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	on_update()

func _on_VisibilityNotifier2D_screen_exited():
	fire_particles.emitting = false

func _on_spawn_timer_timeout() -> void:
	spawn()
