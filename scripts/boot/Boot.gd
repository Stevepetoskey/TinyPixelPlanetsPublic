extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("down")
	yield($AnimationPlayer,"animation_finished")
	yield(get_tree().create_timer(0.2),"timeout")
	$AnimationPlayer.play("fadeIn")
	yield($AnimationPlayer,"animation_finished")
	yield(get_tree().create_timer(2),"timeout")
	$AnimationPlayer.play("zoom")
	yield($AnimationPlayer,"animation_finished")
	var _er = get_tree().change_scene("res://scenes/Menu.tscn")
