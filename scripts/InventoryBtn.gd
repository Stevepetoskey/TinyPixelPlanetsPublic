extends TextureButton

var loc = 0
var mouseIn = false

onready var main = get_node("../../..")

func _ready():
	if main.jRef == loc:
		texture_normal = load("res://textures/GUI/main/inventory_j.png")
	elif main.kRef == loc:
		texture_normal = load("res://textures/GUI/main/inventory_k.png")

func _process(delta):
	if main.visible and mouseIn:
		if Input.is_action_just_pressed("action1"):
			main.inv_btn_action(loc,"j")
		if Input.is_action_just_pressed("action2"):
			main.inv_btn_action(loc,"k")

func _pressed() -> void:
	main.inv_btn_clicked(loc,self)

func _on_InventoryBtn_mouse_entered():
	mouseIn = true
	main.mouse_in_btn(loc)

func _on_InventoryBtn_mouse_exited():
	mouseIn = false
	main.mouse_out_btn(loc)
