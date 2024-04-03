extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false
var clicked = false
signal is_dragging_camera

const CAMERA_ZOOM = 0.1

func _input(event):
	if event.is_action("left_click"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			clicked = true
		else:
			if dragging:
				is_dragging_camera.emit(false)
			clicked = false
			dragging = false
			
	if event is InputEventMouseMotion and clicked:
		if not dragging:
			is_dragging_camera.emit(true)
		dragging = true
		position = (mouse_start_pos - event.position) / zoom + screen_start_position
	
	if event.is_action_pressed("zoom_in"):
		zoom = Vector2(zoom.x + CAMERA_ZOOM, zoom.y + CAMERA_ZOOM)
		
	if event.is_action_pressed("zoom_out"):
		zoom = Vector2(zoom.x - CAMERA_ZOOM, zoom.y - CAMERA_ZOOM)
