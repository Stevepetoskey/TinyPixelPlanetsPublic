extends LineEdit

onready var main = $"../.."
onready var entities = $"../../Entities"

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_C):
		show()
		Global.pause = true

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
		"enemyspawning":
			if commands.size() == 2:
				if commands[1] == "true":
					Global.enemySpawning = true
				elif commands[1] == "false":
					Global.enemySpawning = false
				else:
					print("The second parameter must be true or false")
			else:
				print("Incorrect parameters for the enemyspawning command")
		"entityspawning":
			if commands.size() == 2:
				if commands[1] == "true":
					Global.entitySpawning = true
				elif commands[1] == "false":
					Global.entitySpawning = false
				else:
					print("The second parameter must be true or false")
			else:
				print("Incorrect parameters for the entityspawning command")
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
