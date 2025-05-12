extends Control

var charName = ""
var sex = "male"

var player : Dictionary = {"SkinCol":0,"HairSty":0,"HairCol":0,"EyeSty":0,"EyeCol":0}

var starterCharacters : Dictionary = {"Gerold":{"hair":0,"hairCol":1,"skin":1,"sex":"male"},
	"Micheal":{"hair":2,"hairCol":2,"skin":1,"sex":"male"},
	"Anna":{"hair":1,"hairCol":5,"skin":3,"sex":"female"},
	"Kain":{"hair":0,"hairCol":6,"skin":9,"sex":"male"}
}

var randMNames : Array = ["Kevin","Robert","Josue","Oliver","Unique Name","Patrick","Benjamin","Mateo","Logan","Ezra","Luca","Miles","Ian","Xavier"]
var randFNames : Array = ["Olivia","Emma","Aria","Lily","Zoe","Naomi","Ruby","Natalia","Navaeh","Jade","Clara","Maria","Julia","Charlie","Daisy","Ashley","Scarlet"]

var skinColors : Array = [Color("EED0B6"),Color("F8DEC3"),Color("EDE0C8"),Color("EEC695"),Color("E8BE94"),Color("ECBF84"),Color("CD9564"),Color("AD8B66"),Color("986842"),Color("7F4829"),Color("5B3E2A"),Color("442917")]
var hairColors : Array = [Color("aa8866"),Color("debe99"),Color("241c11"),Color("4f1a00"),Color("9a3300"),Color("4b3832"),Color("3c2f2f"),Color("f6a192"),Color("c2f2d0"),Color("ffcb85"),Color("df3e23"),Color("588dbe")]
var hairStyles : Array = ["Short","Long","Beard","Farmer","Bald","Beard_bald","Low_cut","Waves","Ponytail"]
var eyeColors : Array = [Color("3877ff"),Color("58c982"),Color("ffabfb"),Color("602c00"),Color("31e17b"),Color("7497BE"),Color("E7E8EA"),Color("BBC4DC"),Color("9B9A9D"),Color("C1A56D"),Color("849F9B"),Color("#7D7A5A"),Color("553A20"),Color("5D4D36"),Color("3B2517"),Color("A3634A")]

var fHair = [0,1,3,4,6,7,8]
var mHair = [0,2,4,5,6,7,8]

@onready var maxes : Dictionary = {"SkinCol":skinColors.size(),"HairSty":hairStyles.size(),"HairCol":hairColors.size(),"EyeSty":GlobalData.eyes.size(),"EyeCol":eyeColors.size()}
@onready var load_save: Control = $"../loadSave"

func open():
	Global.gamerules.clear()
	randomize()
	if randi()%3 == 1:
		var character = starterCharacters.keys()[randi()%starterCharacters.size()]
		charName = character
		player["SkinCol"] = starterCharacters[character]["skin"]
		player["HairCol"] = starterCharacters[character]["hairCol"]
		player["HairSty"] = starterCharacters[character]["hair"]
		genCharacter(starterCharacters[character]["sex"])
	else:
		if randi()%2==1:
			genCharacter("male")
		else:
			genCharacter("female")
	$Char/AnimationPlayer.play("idle")
	update_char()
	$Name.text = charName
	if sex == "male":
		$Male.disabled = true
	else:
		$Female.disabled = true
	show()

func genCharacter(charSex : String):
	sex = charSex
	if charSex == "male":
		$Female.button_pressed = false
		$Male.disabled = true
		$Female.disabled = false
		$Female.z_index = 0
		$Male.z_index = 1
		randMNames.shuffle()
		charName = randMNames[0]
		mHair.shuffle()
		player["HairSty"] = mHair[0]
	else:
		$Male.button_pressed = false
		$Female.disabled = true
		$Male.disabled = false
		$Female.z_index = 1
		$Male.z_index = 0
		randFNames.shuffle()
		charName = randFNames[0]
		fHair.shuffle()
		player["HairSty"] = fHair[0]
	player["SkinCol"] = randi_range(0,skinColors.size()-1)
	player["HairCol"] = randi_range(0,hairColors.size()-1)
	player["EyeCol"] = randi_range(0,eyeColors.size()-1)
	player["EyeSty"] = randi_range(0,GlobalData.eyes.size()-1)
	$Name.text = charName

func update_char():
	$Char/Body.texture = load("res://textures/player/base/" + sex + ".png")
	$Char/Armor.texture = load("res://textures/GUI/Menu/character_editor/armor_" + sex + ".png")
	$Char/Body.modulate = skinColors[player["SkinCol"]]
	$Char/Hair.modulate = hairColors[player["HairCol"]]
	$Char/Hair.texture = load("res://textures/player/hair/" + hairStyles[player["HairSty"]] + ".png")
	$Char/Eyes.texture = GlobalData.get_eye_texture(GlobalData.eyes[player["EyeSty"]],eyeColors[player["EyeCol"]],hairColors[player["HairCol"]])

func _on_Name_text_changed(new_text):
	charName = new_text

func _on_back_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	hide()
	load_save.cancel()

func _on_Start_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	Global.playerBase = {"skin":skinColors[player["SkinCol"]],"hair_style":hairStyles[player["HairSty"]],"hair_color":hairColors[player["HairCol"]],"eye_style":player["EyeSty"],"eye_color":eyeColors[player["EyeCol"]],"sex":sex}
	Global.playerName = charName
	load_save.start()

func left(type : String):
	GlobalAudio.play_ui_sound("button_pressed")
	player[type] -= 1
	if player[type] < 0:
		player[type] = maxes[type] - 1
	update_char()

func right(type : String):
	GlobalAudio.play_ui_sound("button_pressed")
	player[type] += 1
	if player[type] > maxes[type] -1:
		player[type] = 0
	update_char()

func _on_Female_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	sex = "female"
	genCharacter(sex)
	update_char()

func _on_Male_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	sex = "male"
	genCharacter(sex)
	update_char()

func _on_Scenarios_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	hide()
	$"../../Scenarios".show()

func _on_Done_pressed():
	GlobalAudio.play_ui_sound("button_pressed")
	$"../../Scenarios".hide()
	show()

func _on_game_settings_btn_pressed() -> void:
	GlobalAudio.play_ui_sound("button_pressed")
	$"../GameSetttings".open()
	hide()
