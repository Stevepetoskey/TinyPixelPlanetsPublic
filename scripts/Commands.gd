extends LineEdit

onready var main = $"../.."
onready var entities = $"../../Entities"
onready var world = $"../../World"
onready var player = $"../../Player"

func _process(delta):
	$"../Hotbar/Coords".text = "X: " + str(stepify(player.position.x / 4.0,0.01)) + ", Y: " + str(stepify(player.position.y/ 4.0,0.01))

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_C):
		show()
		Global.pause = true

func to_bool(s: String) -> bool: #Credit to Poobslag
	var result: bool
	match s:
		"True", "TRUE", "true", "1": result = true
		"False", "FALSE", "false", "0": result = false
		_: result = false if s.empty() else true
	return result

func _on_Commands_text_entered(new_text : String):
	hide()
	clear()
	Global.pause = false
	new_text = new_text.to_lower()
	var commands = new_text.split(" ")
	match commands[0]:
		"godmode":
			if commands.size() == 2:
				if commands[1] == "enable":
					main.enable_godmode()
				elif commands[1] == "disable":
					main.disable_godmode()
				else:
					print("The second parameter must be enable or disable")
			else:
				print("Incorrect parameters for the godmode command")
		"summon":
			if commands.size() == 4:
				var entity = entities.find_entity(commands[1])
				if entity != "":
					if commands[2].is_valid_float() and commands[3].is_valid_float():
						entities.summon_entity(entity,Vector2(float(commands[2]),float(commands[3])))
					else:
						print("X and Y must be floats")
				else:
					print("Entity ",commands[1]," does not exist")
			elif commands.size() == 2:
				var entity = entities.find_entity(commands[1])
				if entity != "":
					entities.summon_entity(entity)
				else:
					print("Entity ",commands[1]," does not exist")
			else:
				print("Incorrect parameters for the summon command")
		"worldrule":
			if commands.size() == 3:
				var rule = commands[1]
				var value = commands[2]
				if world.worldRules.has(rule):
					match world.worldRules[rule]["type"]:
						"bool":
							if ["TRUE","True","true","1","FALSE","False","false","0"].has(value):
								world.worldRules[rule]["value"] = to_bool(value)
							else:
								print("Unexpected value (bool value expected)")
						"int":
							if value.is_valid_integer():
								world.worldRules[rule]["value"] = value.to_int()
							else:
								print("Unexpected value (int value expected)")
						"string":
							world.worldRules[rule]["value"] = value
				else:
					print("Rule " + rule + " does not exist")
			else:
				print("Incorrect parameters for the worldrule command")
		"displaycoordinates":
			if commands.size() == 2:
				var value = commands[1]
				if ["TRUE","True","true","1","FALSE","False","false","0"].has(value):
					$"../Hotbar/Coords".visible = to_bool(value)
				else:
					print("Unexpected value (bool value expected)")
			else:
				print("Incorrect parameters for the displaycoordinates command")
