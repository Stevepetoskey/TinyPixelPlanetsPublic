extends LineEdit

@onready var main = $"../.."
@onready var entities = $"../../Entities"
@onready var world = $"../../World"
@onready var player = $"../../Player"
@onready var command_help: RichTextLabel = $CommandHelp

var commandList = [
	"worldrule [rule] [value]",
	"godmode [enable/ disable]",
	"summon [entity] [x position] [y position]",
	"displaycoordinates [bool]",
	"weather [weather event]"
]

func _process(delta):
	$"../Hotbar/Coords".text = "X: " + str(snapped(player.position.x / 4.0,0.01)) + ", Y: " + str(snapped(player.position.y/ 4.0,0.01))

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_C):
		show()
		Global.pause = true

func to_bool(s: String) -> bool: #Credit to Poobslag
	var result: bool
	match s:
		"True", "TRUE", "true", "1": result = true
		"False", "FALSE", "false", "0": result = false
		_: result = false if s.is_empty() else true
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
							if ["true","1","false","0"].has(value):
								world.worldRules[rule]["value"] = to_bool(value)
							else:
								print("Unexpected value (bool value expected)")
						"int":
							if value.is_valid_int():
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
				if ["true","1","false","0"].has(value):
					$"../Hotbar/Coords".visible = to_bool(value)
				else:
					print("Unexpected value (bool value expected)")
			else:
				print("Incorrect parameters for the displaycoordinates command")
		"weather":
			if commands.size() == 2:
				var weather = commands[1]
				if ["rain","showers","snow","blizzard","none"].has(weather):
					$"../..".weather_event(false,[200,500], weather)
				else:
					print("Unkown weather event " + weather)
			else:
				print("Incorrect parameters for the weather command")

func return_text_matches(toMatch : Array, matchTo : String) -> Array:
	var matches : Array = toMatch.duplicate()
	var toRemove : Array = []
	for string in toMatch:
		for i in range(matchTo.length()):
			if matchTo.length() > string.length() or string[i] != matchTo[i]:
				toRemove.append(string)
				break
	for remove in toRemove:
		matches.erase(remove)
	return matches

func _on_text_changed(new_text: String) -> void:
	command_help.text = ""
	new_text = new_text.to_lower()
	var commands : Array = new_text.split(" ")
	if commands.size() <= 1:
		var possibleCommands : Array = return_text_matches(commandList.duplicate(),new_text)
		for command : String in possibleCommands:
			command_help.text += command + "\n"
	else:
		match commands[0]:
			"godmode":
				var possibleCommands : Array = return_text_matches(["enable","disable"],commands[1])
				for command : String in possibleCommands:
					command_help.text += command + "\n"
			"summon":
				if commands.size() <= 2:
					var possibleCommands : Array = return_text_matches(entities.entities.keys(),commands[1])
					for command : String in possibleCommands:
						command_help.text += command + "\n"
				else:
					command_help.text = "summon [entity]\nsummon [entity] [x position] [y position]"
			"worldrule":
				if commands.size() <= 2:
					var possibleCommands : Array = return_text_matches(world.worldRules.keys(),commands[1])
					for command : String in possibleCommands:
						command_help.text += command + "\n"
				elif world.worldRules.has(commands[1]):
					command_help.text = "worldrule " + commands[1] + " ["+ world.worldRules[commands[1]]["type"] + "]"
				else:
					command_help.text = "worldrule [rule] [value]"
			"displaycoordinates":
				var possibleCommands : Array = return_text_matches(["true","1","false","0"],commands[1])
				for command : String in possibleCommands:
					command_help.text += command + "\n"
			"weather":
				var possibleCommands : Array = return_text_matches(["rain","showers","snow","blizzard","none"],commands[1])
				for command : String in possibleCommands:
					command_help.text += command + "\n"
