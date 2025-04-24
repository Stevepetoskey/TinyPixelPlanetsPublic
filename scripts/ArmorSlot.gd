extends TextureButton

@export var type : String
@export var deco : bool

@onready var armor = get_node("../..")
@onready var world = get_node("../../../../../World")

signal armor_btn_pressed

func _ready():
	self.connect("mouse_entered", Callable(armor, "mouse_in_btn").bind(name))
	self.connect("mouse_exited", Callable(armor, "mouse_out_btn").bind(name))

func _process(delta):
	if visible:
		if armor.armor[name].is_empty():
			$Sprite2D.texture = load("res://textures/GUI/main/Armor/" + name.to_lower() + ".png")
		else:
			$Sprite2D.texture = GlobalData.get_item_texture(armor.armor[name]["id"])

func _pressed():
	emit_signal("armor_btn_pressed",self)
