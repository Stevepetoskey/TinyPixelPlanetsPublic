extends TextureButton

export var type : String
export var deco : bool

onready var armor = get_node("../..")
onready var world = get_node("../../../../../World")

signal armor_btn_pressed

func _ready():
	self.connect("mouse_entered",armor,"mouse_in_btn",[name])
	self.connect("mouse_exited",armor,"mouse_out_btn",[name])

func _process(delta):
	if visible:
		if armor.armor[name].empty():
			$Sprite.texture = load("res://textures/GUI/main/Armor/" + name.to_lower() + ".png")
		else:
			$Sprite.texture = world.get_item_texture(armor.armor[name]["id"])

func _pressed():
	emit_signal("armor_btn_pressed",self)
