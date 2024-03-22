extends TextureRect

const GRAY_BTN = preload("res://textures/GUI/Menu/scenario_btn_selected.png")
const BLUE_BTN = preload("res://textures/GUI/Menu/scenario_btn.png")

var currentScenario = "sandbox"

var scenarios = {
	"sandbox":{
		"icon":preload("res://textures/GUI/Menu/sandbox_icon.png"),
		"title":"Sandbox",
		"desc":"Explore the pixel cosmos and create your own story.",
		"stars":0
	},
	"temple":{
		"icon":preload("res://textures/GUI/Menu/temple_icon.png"),
		"title":"The temple",
		"desc":"You must explore an ancient temple on a far away planet. Find the secrets the temple hides beneath the surface.",
		"stars":1
	},
	"meteor":{
		"icon":preload("res://textures/GUI/Menu/meteor_icon.png"),
		"title":"Meteor shower",
		"desc":"You are stranded on a planet and a commet is on its way.",
		"stars":3
	},
	"planatius":{
		"icon":preload("res://textures/GUI/Menu/planatius_icon.png"),
		"title":"planatius",
		"desc":"Planatius has awoken, and is coming for you. Don’t stay on any one planet for too long, or else it will find you. You must craft a rare weapon that will allow you to destroy it. The longer you take to complete this task, the more powerful Planatius becomes.",
		"stars":4
	},
	"insane":{
		"icon":preload("res://textures/GUI/Menu/insane_icon.png"),
		"title":"Insane 100%",
		"desc":"You must complete all achievements with 1 hp and no respawns.",
		"stars":5
	},
	"empty":{
		"icon":preload("res://textures/GUI/Menu/empty_icon.png"),
		"title":"Empty",
		"desc":"No scenario",
		"stars":0
	},
}

func scenario_btn_pressed(id):
	Global.scenario = id
	currentScenario = id
	#Sets all buttons but the one pressed to blue
	for child in $ScrollContainer/VBoxContainer.get_children():
		if child.scenarioId != id:
			child.texture_normal = BLUE_BTN
		else:
			child.texture_normal = GRAY_BTN
	$Title.text = scenarios[id]["title"]
	$Desc.text = scenarios[id]["desc"]
	$"../World/character/CurrentScenario/Icon".texture = scenarios[id]["icon"]
	$"../World/character/CurrentScenario/Title".text = scenarios[id]["title"]
