extends TextureButton

var mouseIn = false
var id : int = 0
var data : Dictionary = {}

@onready var godmode = $"../../.."

func _process(delta: float) -> void:
	if godmode.visible and mouseIn:
		if Input.is_action_just_pressed("build"):
			godmode.inv_btn_action(id,data,0)
		if Input.is_action_just_pressed("build2"):
			godmode.inv_btn_action(id,data,1)

func _on_mouse_entered() -> void:
	mouseIn = true
	godmode.mouse_in_btn(id,data)

func _on_mouse_exited() -> void:
	mouseIn = false
	godmode.mouse_out_btn()
