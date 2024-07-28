extends Camera2D

var mouse_start_pos
var screen_start_position

@export var thresholds:LightThresholds
@export var gameState:GameState
@export var env:WorldEnvironment
var dragging = false
var clicked = false
signal is_dragging_camera
const MAX_SHAKE=5
const CAMERA_ZOOM = 0.1
const SCROLL_SPEED = 100
const MIN_RECOGNIZABLE_DRAG_DISTANCE = 10
const MAX_ZOOM_OUT = 0.45
const MAX_ZOOM_IN = 2
const VIEW_RANGE_TOLERANCE = 200
var lastpos=0
var original_position=0;
var shake_timer=0;
var duration=0;
var intensity=0;


func shake(duration: float, intensity: float,position,maxval=MAX_SHAKE):
	if intensity>maxval: return;
	if abs(abs(position.y)-abs(position.y))>1000:return

	if intensity>MAX_SHAKE: return
	shake_timer = 0.0
	self.duration=duration;
	self.intensity=self.intensity+intensity

func isOffCamera(position):
	var diff= abs(abs(position.y)-abs(global_position.y))
	return diff>1000


func _process(delta):
	if shake_timer < duration:
		var x_offset = randf_range(-intensity, intensity)
		var y_offset = randf_range(-intensity, intensity)
				
		offset.x =x_offset/zoom.x
		offset.y =y_offset/zoom.x
		duration=duration-1*delta
		if intensity>0:intensity=intensity-1*delta

	lastpos=global_position.y

func _ready():
	
	Projectile.camera=self;
	Turret.camera=self;
	pass;
	
func _input(event):
	if InputUtils.is_action_just_pressed(event, "left_click"):
		mouse_start_pos = event.position
		screen_start_position = position
		clicked = true
		
	if InputUtils.is_action_just_released(event, "left_click"):
		clicked = false
		dragging = false
		#is_dragging_camera.emit(false)
	#if event.is_action("left_click"):
		#if event.is_pressed():
			#mouse_start_pos = event.position
			#screen_start_position = position
			#clicked = true
		#else:
			#if dragging:
				#is_dragging_camera.emit(false)
			#clicked = false
			#dragging = false
			
	if event is InputEventMouseMotion and clicked:
		var drag_distance = mouse_start_pos.distance_to(event.position)
		#Player has to drag for a minimum distance to be recognized as dragging motion
		if not dragging:
			if drag_distance < MIN_RECOGNIZABLE_DRAG_DISTANCE: 
				return
			is_dragging_camera.emit(true)

		dragging = true

		var new_pos = (mouse_start_pos - event.position) / zoom + screen_start_position
		if new_pos.x > 0:
			if new_pos.x < (GameboardConstants.BOARD_WIDTH)*GameboardConstants.TILE_SIZE:
				if new_pos.y > -VIEW_RANGE_TOLERANCE and new_pos.y < (GameboardConstants.BOARD_HEIGHT * GameboardConstants.TILE_SIZE) + VIEW_RANGE_TOLERANCE:
					position = new_pos
	
	if event.is_action_pressed("scroll_up"):
		if zoom.x < MAX_ZOOM_IN:
			zoom = Vector2(zoom.x + CAMERA_ZOOM, zoom.y + CAMERA_ZOOM)

	if event.is_action_pressed("scroll_down"):
		if zoom.x > MAX_ZOOM_OUT:
			zoom = Vector2(zoom.x - CAMERA_ZOOM, zoom.y - CAMERA_ZOOM)

var tween
func move_to(position: Vector2, done: Callable):
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", position, GameplayConstants.CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): done.call())
