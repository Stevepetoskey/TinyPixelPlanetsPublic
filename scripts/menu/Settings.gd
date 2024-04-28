extends Panel

var changingKeybind : String

var allowedKeybinds = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
var allowedMousebinds = {1:"LMB",2:"RMB",3:"MMB",8:"XMB1",9:"XMB2",4:"MBWU",5:"MBWD"}

@onready var disable_controls: TextureRect = $"../DisableControls"
@onready var keybind_container: VBoxContainer = $ScrollContainer/VBoxContainer/KeybindContainer
@onready var music_slider: HSlider = $ScrollContainer/VBoxContainer/MusicSlider

func _ready() -> void:
	music_slider.value = Global.settings["music"]
	$"../AudioStreamPlayer".volume_db = (Global.settings["music"] * 5) - 50
	if Global.settings["music"] == 0:
		$"../AudioStreamPlayer".volume_db = -100
	for keybind in Global.settings["keybinds"]:
		InputMap.action_erase_events(keybind)
		var keybindData = Global.settings["keybinds"][keybind]
		if keybindData["event_type"] == "mouse":
			var newInput = InputEventMouseButton.new()
			newInput.button_index = keybindData["id"]
			InputMap.action_add_event(keybind,newInput)
			keybind_container.get_node(keybind + "/KeyBind").text = "> " + allowedMousebinds[keybindData["id"]] + " <"
		else:
			var newInput = InputEventKey.new()
			newInput.keycode = keybindData["id"]
			InputMap.action_add_event(keybind,newInput)
			keybind_container.get_node(keybind + "/KeyBind").text = "> " + newInput.as_text() + " <"
	disable_controls.hide()
	for keybind in keybind_container.get_children():
		keybind.get_node("KeyBind").connect("pressed", Callable(self, "keybind_button_pressed").bind(keybind.get_node("KeyBind")))

func keybind_button_pressed(keybindBtn : Button) -> void:
	keybindBtn.text = "> <"
	changingKeybind = keybindBtn.get_parent().name
	disable_controls.show()

func _unhandled_input(event: InputEvent) -> void:
	if changingKeybind != "" and allowedKeybinds.has(event.as_text()):
		InputMap.action_erase_events(changingKeybind)
		InputMap.action_add_event(changingKeybind,event)
		keybind_container.get_node(changingKeybind + "/KeyBind").text = "> " + event.as_text() + " <"
		Global.settings["keybinds"][changingKeybind] = {"event_type":"key","id":event.keycode}
		disable_controls.hide()
		Global.save_settings()
		changingKeybind = ""

func _on_DisableControls_gui_input(event: InputEvent) -> void:
	if changingKeybind != "" and (allowedKeybinds.has(event.as_text()) or (event.get_class() == "InputEventMouseButton" and allowedMousebinds.has(event.button_index))):
		InputMap.action_erase_events(changingKeybind)
		InputMap.action_add_event(changingKeybind,event)
		if event.get_class() == "InputEventMouseButton":
			keybind_container.get_node(changingKeybind + "/KeyBind").text = "> " + allowedMousebinds[event.button_index] + " <"
			Global.settings["keybinds"][changingKeybind] = {"event_type":"mouse","id":event.button_index}
		else:
			keybind_container.get_node(changingKeybind + "/KeyBind").text = "> " + event.as_text() + " <"
			Global.settings["keybinds"][changingKeybind] = {"event_type":"key","id":event.keycode}
		disable_controls.hide()
		Global.save_settings()
		changingKeybind = ""

func _on_MusicSlider_value_changed(value: float) -> void:
	Global.settings["music"] = int(value)
	$"../AudioStreamPlayer".volume_db = (value * 5) - 50
	if Global.settings["music"] == 0:
		$"../AudioStreamPlayer".volume_db = -100
	Global.save_settings()
