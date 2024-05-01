extends Camera2D

var mouse_start_pos
var screen_start_position
@export var brightness:CanvasModulate
var baseBrightness;
@export var thresholds:LightThresholds
@export var gameState:GameState
var dragging = false
var clicked = false
signal is_dragging_camera

const CAMERA_ZOOM = 0.1
const SCROLL_SPEED = 100
const MIN_RECOGNIZABLE_DRAG_DISTANCE = 10
func _ready():
	Projectile.camera=self;
	Turret.camera=self;
	pass;
func changeBrightness():
	if baseBrightness==null:
		baseBrightness=brightness.color
	brightness.color=baseBrightness*thresholds.getDark(gameState.y)
	pass;
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
		var drag_distance = mouse_start_pos.distance_to(event.position)
		#Player has to drag for a minimum distance to be recognized as dragging motion
		if not dragging and drag_distance < MIN_RECOGNIZABLE_DRAG_DISTANCE: 
			return
		if not dragging:
			is_dragging_camera.emit(true)
		dragging = true
		position = (mouse_start_pos - event.position) / zoom + screen_start_position
	
	if event.is_action_pressed("scroll_up"):
		if Input.is_action_pressed("control"):
			zoom = Vector2(zoom.x + CAMERA_ZOOM, zoom.y + CAMERA_ZOOM)
		else:
			position -= Vector2(0, SCROLL_SPEED) / zoom
			#changeBrightness()
	if event.is_action_pressed("scroll_down"):
		if Input.is_action_pressed("control"):
			
			zoom = Vector2(zoom.x - CAMERA_ZOOM, zoom.y - CAMERA_ZOOM)
		else:
			position += Vector2(0, SCROLL_SPEED) / zoom
			#changeBrightness()
		
	
		
