extends TextureButton

var loc = 0
var mouseIn = false

@onready var inventory = $"../../.."

func _ready():
	if inventory.jRef == loc:
		texture_normal = load("res://textures/GUI/main/inventory/inventory_j.png")
	elif inventory.kRef == loc:
		texture_normal = load("res://textures/GUI/main/inventory/inventory_k.png")

func _process(_delta):
	if inventory.visible and mouseIn:
		if Input.is_action_just_pressed("action1"):
			inventory.inv_btn_action(loc,"j")
		if Input.is_action_just_pressed("action2"):
			inventory.inv_btn_action(loc,"k")
		if Input.is_action_just_pressed("build2"):
			inventory.inv_btn_action(loc,"right_click")

func _pressed() -> void:
	inventory.inv_btn_clicked(loc,self)

func _on_InventoryBtn_mouse_entered():
	mouseIn = true
	inventory.mouse_in_btn(loc)

func _on_InventoryBtn_mouse_exited():
	mouseIn = false
	inventory.mouse_out_btn()
