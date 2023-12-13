extends Control

var charName = ""
var skinCol = 0
var hairCol = 0
var hairSty = 0
var sex = "Guy"

var starterCharacters = {"Gerold":{"hair":0,"hairCol":1,"skin":1,"sex":"Guy"},
	"Micheal":{"hair":2,"hairCol":2,"skin":1,"sex":"Guy"},
	"Anna":{"hair":1,"hairCol":5,"skin":3,"sex":"Woman"},
	"Kain":{"hair":0,"hairCol":6,"skin":9,"sex":"Guy"}
}

var randMNames = ["Kevin","Robert","Josue","Oliver","Unique Name","Patrick","Benjamin","Mateo","Logan","Ezra","Luca","Miles","Ian","Xavier"]
var randFNames = ["Olivia","Emma","Aria","Lily","Zoe","Naomi","Ruby","Natalia","Navaeh","Jade","Clara","Maria","Julia","Charlie","Daisy","Ashley","Scarlet"]

var skinColors = [Color("EED0B6"),Color("F8DEC3"),Color("EDE0C8"),Color("EEC695"),Color("E8BE94"),Color("ECBF84"),Color("CD9564"),Color("AD8B66"),Color("986842"),Color("7F4829"),Color("5B3E2A"),Color("442917")]
var hairColors = [Color("aa8866"),Color("debe99"),Color("241c11"),Color("4f1a00"),Color("9a3300"),Color("4b3832"),Color("3c2f2f"),Color("f6a192"),Color("c2f2d0"),Color("ffcb85")]
var hairStyles = ["Short","Long","Beard","Farmer"]

var fHair = [0,1]
var mHair = [0,2]

func open():
	randomize()
	if randi()%3 == 1:
		var character = starterCharacters.keys()[randi()%starterCharacters.size()]
		charName = character
		skinCol = starterCharacters[character]["skin"]
		hairCol = starterCharacters[character]["hairCol"]
		hairSty = starterCharacters[character]["hair"]
		sex = starterCharacters[character]["sex"]
	else:
		if randi()%2==1:
			genCharacter("Guy")
		else:
			genCharacter("Woman")
	$Char/AnimationPlayer.play("idle")
	update_char()
	$Name.text = charName
	if sex == "Guy":
		$Male.disabled = true
	else:
		$Female.disabled = true
	show()

func genCharacter(charSex : String):
	sex = charSex
	if charSex == "Guy":
		randMNames.shuffle()
		charName = randMNames[0]
		mHair.shuffle()
		hairSty = mHair[0]
	else:
		randFNames.shuffle()
		charName = randFNames[0]
		fHair.shuffle()
		hairSty = fHair[0]
	skinCol = randi()%skinColors.size()
	hairCol = randi()%hairColors.size()
	$Name.text = charName

func update_char():
	$Char/Body.texture = load("res://textures/player/Body/" + sex + ".png")
	$Char/Armor.texture = load("res://textures/GUI/Menu/armor-" + sex + ".png")
	$Char/Body.modulate = skinColors[skinCol]
	$Char/Hair.modulate = hairColors[hairCol]
	$Char/Hair.texture = load("res://textures/player/Hair/" + hairStyles[hairSty] + ".png")

func _on_Name_text_changed(new_text):
	charName = new_text

func _on_back_pressed():
	hide()
	get_node("../loadSave").cancel()

func _on_Start_pressed():
	Global.playerBase = {"skin":skinColors[skinCol],"hair_style":hairStyles[hairSty],"hair_color":hairColors[hairCol],"sex":sex}
	get_node("../loadSave").start()

func left(type : String):
	match type:
		"SkinCol":
			skinCol -= 1
			if skinCol < 0:
				skinCol = skinColors.size()-1
		"HairCol":
			hairCol -= 1
			if hairCol < 0:
				hairCol = hairColors.size()-1
		"HairSty":
			hairSty -= 1
			if hairSty < 0:
				hairSty = hairStyles.size()-1
	update_char()

func right(type : String):
	match type:
		"SkinCol":
			skinCol += 1
			if skinCol > skinColors.size()-1:
				skinCol = 0
		"HairCol":
			hairCol += 1
			if hairCol > hairColors.size()-1:
				hairCol = 0
		"HairSty":
			hairSty += 1
			if hairSty > hairStyles.size()-1:
				hairSty = 0
	update_char()

func _on_Female_pressed():
	sex = "Woman"
	genCharacter(sex)
	$Male.pressed = false
	$Female.disabled = true
	$Male.disabled = false
	update_char()

func _on_Male_pressed():
	sex = "Guy"
	genCharacter(sex)
	$Female.pressed = false
	$Male.disabled = true
	$Female.disabled = false
	update_char()
