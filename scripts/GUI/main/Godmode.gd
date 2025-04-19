extends Control

const ITEM = preload("res://assets/GUI/godmode_item_btn.tscn")

@onready var tabs: HBoxContainer = $Tabs
@onready var item_hold: GridContainer = $ScrollContainer/ItemHold
@onready var inventory: Control = $"../Inventory"
@onready var world: Node2D = $"../../World"

var godmodeInventory = {
	"building_blocks":[8,13,15,19,20,23,26,27,30,72,75,79,80,81,82,83,84,86,87,88,89,90,195,108,109,110,111,133,134,135,136,137,138,157,162,163,164,173,174,175,180,181,182,183,188,201,202,203,204,245,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,273,274,275,276,277,278,279,280,281,282,300,302,303],
	"nature_blocks":[1,2,3,6,7,9,10,11,14,17,18,21,22,24,25,29,55,69,70,71,73,76,77,78,85,104,105,106,107,112,118,119,120,124,128,144,146,147,148,149,150,151,152,153,154,155,156,160,161,177,178,179,184,192,194,196,197,198,199,200,217,218,219,220,221,294,295,296,297,298,283,284,285,286,290,291,292,322,324],
	"functional_blocks":[12,16,28,91,145,158,159,166,167,168,169,170,171,172,176,216,241,242,243,246,263,265,266,267,268,269,264,270,271,272,301,320,321,325,326,327,328],
	"food":[125,126,127,140,304],
	"tools":[4,58,59,60,61,62,92,93,94,95,31,129,54,53,63,64,65,57,130,66,67,68,98,96,97,99,131,132],
	"wearables":[35,36,37,38,39,40,41,42,46,47,48,49,207,208,209,210,211,212,213,214,215],
	"misc":[5,52,56,74,100,101,102,103,165,193,113,114,115,116,121,122,123,139,141,142,143,190,191,205,206,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,244,287,288,289,323],
	"dev":[185,186,187,189,293]
}

func _ready() -> void:
	for tab in tabs.get_children():
		tab.connect("pressed",set_tab.bind(tab.name))

func pop_up(value : bool) -> void:
	set_tab("building_blocks")
	visible = value

func set_tab(tab : String) -> void:
	for tabBtn : TextureButton in tabs.get_children():
		tabBtn.disabled = tabBtn.name == tab
	for itemBtn : TextureButton in item_hold.get_children():
		itemBtn.queue_free()
	for id : int in godmodeInventory[tab]:
		match id:
			215:
				for upgrade in world.upgrades:
					create_item_btn(id,{"upgrade":upgrade})
			_:
				create_item_btn(id)

func create_item_btn(id : int,data := {}) -> void:
	var itemBtn = ITEM.instantiate()
	itemBtn.id = id
	itemBtn.data = data
	itemBtn.get_node("Item").texture = GlobalData.get_item_texture(id)
	item_hold.add_child(itemBtn)

func mouse_in_btn(id : int, data : Dictionary):
	var itemData = GlobalData.get_item_data(id)
	if itemData.has("name"):
		var text = itemData["name"]
		if itemData.has("desc"):
			text += "\n" + itemData["desc"]
		if data.has("upgrade") and world.upgrades.has(data["upgrade"]):
			text += "\n[color=Palegoldenrod]" + world.upgrades[data["upgrade"]]["name"] + "[/color]"
		$"../ItemData".show()
		$"../ItemData".text = text

func mouse_out_btn():
	$"../ItemData".hide()

func inv_btn_action(id : int,data : Dictionary,mode := 0) -> void:
	var itemData = GlobalData.get_item_data(id)
	var stackSize = inventory.ITEM_STACK_SIZE if !itemData.has("stack_size") else itemData["stack_size"]
	var actualData : Dictionary = {} if !GlobalData.get_item_data(id).has("starter_data") else GlobalData.get_item_data(id)["starter_data"]
	actualData.merge(data,true)
	inventory.insert_item_in_inventory(mode,{"id":id,"amount":stackSize,"data":actualData.duplicate(true)})
	inventory.update_inventory()
