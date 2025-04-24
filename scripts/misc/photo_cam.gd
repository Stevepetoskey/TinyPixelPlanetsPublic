extends Camera2D

var CAMERA_SPEED : float = 1

var inControl : bool = false
var paused : bool = false

func _process(delta):
	if Input.is_action_just_pressed("switch_camera"):
		inControl = !inControl
		paused = false
		position = $"../Player".position
		zoom = Vector2(1,1)
		$"../CanvasLayer/Hotbar".visible = !inControl
		$"../Cursor".visible = !inControl
		$"../Player".inControl = !inControl
		$"../Player/PlayerCamera".enabled = !inControl
		$"../CanvasLayer/CameraControls".hide()
		enabled = inControl
	if Input.is_action_just_pressed("pause_camera"):
		paused = !paused
		$"../Player".inControl = paused
		#$"../CanvasLayer/CameraControls".visible = paused
	if inControl and !paused:
		if Input.is_action_pressed("move_left"):
			position.x -= CAMERA_SPEED
		elif Input.is_action_pressed("move_right"):
			position.x += CAMERA_SPEED
		if Input.is_action_pressed("jump"):
			position.y -= CAMERA_SPEED
		elif Input.is_action_pressed("down"):
			position.y += CAMERA_SPEED
		if Input.is_action_just_pressed("zoom_in"):
			zoom += Vector2(0.1,0.1)
		elif Input.is_action_just_pressed("zoom_out"):
			zoom -= Vector2(0.1,0.1)

func _on_less_speed_btn_pressed():
	if CAMERA_SPEED > 0:
		CAMERA_SPEED -= 0.1

func _on_set_speed_btn_pressed():
	CAMERA_SPEED = 1

func _on_more_speed_btn_pressed():
	CAMERA_SPEED += 0.1
