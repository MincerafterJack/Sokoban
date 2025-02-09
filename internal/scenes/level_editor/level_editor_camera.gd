extends Camera2D


var dragging:bool = false


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if not dragging and event.pressed:
				dragging = true
			if dragging and not event.pressed:
				dragging = false
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			set_zoom(get_zoom() * 2.0)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			set_zoom(get_zoom() * 0.5)

	if event is InputEventMouseMotion and dragging:
		position -= event.relative / get_zoom().x


func _physics_process(delta):
	if Input.is_action_pressed("camera_up"):
		position += Vector2.UP / get_zoom().x * 20.0
	if Input.is_action_pressed("camera_down"):
		position += Vector2.DOWN / get_zoom().x * 20.0
	if Input.is_action_pressed("camera_left"):
		position += Vector2.LEFT / get_zoom().x * 20.0
	if Input.is_action_pressed("camera_right"):
		position += Vector2.RIGHT / get_zoom().x * 20.0
	
	if Input.is_action_just_pressed("zoom_in"):
		set_zoom(get_zoom() * 2.0)
	if Input.is_action_just_pressed("zoom_out"):
		set_zoom(get_zoom() * 0.5)
