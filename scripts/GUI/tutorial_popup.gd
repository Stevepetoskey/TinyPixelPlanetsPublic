extends Panel

var currentTutorial : String = "none"
var timedTutorial : String = "none"
var charIndex : int = 0
var tutorialContent : String
var showOk : bool

var queuedTutorials : Dictionary = {}

@onready var show_timer: Timer = $ShowTimer
@onready var content: RichTextLabel = $VBoxContainer/Content
@onready var text_timer: Timer = $TextTimer
@onready var icon: TextureRect = $VBoxContainer/Icon

func append_tutorial(groupId : String, tutorialId : String, showOkBtn : bool = false, showTime : float = -1, dir : String = "left") -> void:
	if !$"..".completedTutorials.has(tutorialId):
		if !queuedTutorials.has(tutorialId):
			queuedTutorials[tutorialId] = {"group_id":groupId,"tutorial_id":tutorialId,"show_ok_btn":showOkBtn,"dir":dir}
		if currentTutorial == "none":
			var firstTutorial = queuedTutorials[queuedTutorials.keys()[0]]
			display_tutorial(firstTutorial["group_id"],firstTutorial["tutorial_id"],firstTutorial["show_ok_btn"],-1,firstTutorial["dir"])

func display_tutorial(groupId : String, tutorialId : String, showOkBtn : bool = false, showTime : float = -1, dir : String = "left") -> void:
	currentTutorial = tutorialId
	match dir:
		"left":
			anchor_left = 0
			anchor_right = 0
			offset_left = 0
			offset_right = 94
			grow_horizontal = GrowDirection.GROW_DIRECTION_END
		"right":
			anchor_left = 1
			anchor_right = 1
			offset_left = -94
			offset_right = 0
			grow_horizontal = GrowDirection.GROW_DIRECTION_BEGIN
	var tutorialData : Dictionary = GlobalGui.tutorials[groupId]["sub_tutorials"][tutorialId]
	$VBoxContainer/Title.text = tutorialData["display_name"]
	if tutorialData["icon"] != "none":
		icon.show()
		icon.texture = load(tutorialData["icon"])
	else:
		icon.hide()
	content.visible_characters = 0
	show()
	$VBoxContainer/OkBtn.hide()
	tutorialContent = tutorialData["content"]
	charIndex = 0
	showOk = showOkBtn
	content.text = tutorialContent
	_on_text_timer_timeout()

func text_finished() -> void:
	$VBoxContainer/OkBtn.visible = showOk
	await get_tree().process_frame
	content.scroll_to_line(content.get_line_count())

func close(next : bool = false,complete : bool = false) -> void:
	hide()
	if complete and !GlobalGui.completedTutorials.has(currentTutorial):
		GlobalGui.completedTutorials.append(currentTutorial)
	currentTutorial = "none"
	text_timer.stop()
	show_timer.stop()
	if next and queuedTutorials.size() > 1:
		queuedTutorials.erase(queuedTutorials.keys()[0])
		var firstTutorial = queuedTutorials[queuedTutorials.keys()[0]]
		display_tutorial(firstTutorial["group_id"],firstTutorial["tutorial_id"],firstTutorial["show_ok_btn"],-1,firstTutorial["dir"])
	else:
		queuedTutorials.clear()

func _on_show_timer_timeout() -> void:
	GlobalGui.completedTutorials.append(timedTutorial)
	if currentTutorial == timedTutorial:
		GlobalGui.tutorial_closed.emit()
		close(true)

func _on_ok_btn_pressed() -> void:
	GlobalGui.completedTutorials.append(currentTutorial)
	GlobalGui.tutorial_closed.emit()
	close(true)

func _on_text_timer_timeout() -> void:
	content.visible_characters += 1
	content.scroll_to_line(max(content.get_character_line(charIndex)-5,0))
	if charIndex >= tutorialContent.length()-1:
		text_finished()
	else:
		text_timer.start(0.3 if ["!","?",",","."].has(tutorialContent[charIndex]) else 0.05)
		charIndex += 1
