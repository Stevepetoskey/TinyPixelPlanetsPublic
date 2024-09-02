extends Panel

var currentBlock : LogicBlock

@onready var time_lbl: Label = $VBoxContainer/TimeLbl
@onready var slider: HSlider = $VBoxContainer/Slider

func pop_up(block : LogicBlock) -> void:
	currentBlock = block
	slider.value = block.data["wait_time"]
	update_data()
	show()

func update_data() -> void:
	time_lbl.text = "Wait time: " + str(currentBlock["data"]["wait_time"]) + " seconds"

func _on_slider_value_changed(value: float) -> void:
	currentBlock.data["wait_time"] = value
	update_data()

func _on_save_btn_pressed() -> void:
	hide()
