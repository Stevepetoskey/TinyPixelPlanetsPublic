extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _process(delta):
	$Path2D/PathFollow2D.offset += delta

# Called when the node enters the scene tree for the first time.
func _ready():
	#yield(get_tree().create_timer(0.5),"timeout")
	$Main/Title.modulate = Color(1,1,1,0)
	$AnimationPlayer.play("zoom")
	yield($AnimationPlayer,"animation_finished")
	$blank.hide()
	$Main/Title.show()
	$AnimationPlayer.play("title")
	yield($AnimationPlayer,"animation_finished")
	$Main/Buttons.show()
	$AnimationPlayer.play("buttons")

func _on_Play_pressed():
	$Main.hide()
	$World/character.hide()
	$World/loadSave.show()
	$World/loadSave.update_save_list()
	$World.show()

func _on_back_pressed():
	$Credits.hide()
	$World.hide()
	$Main.show()

func _on_Credits_pressed():
	$Main.hide()
	$Credits.show()

func _on_Tutorial_pressed():
	$World/loadSave.start(true)
