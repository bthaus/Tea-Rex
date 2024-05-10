extends Camera2D

var mouse_start_pos
var screen_start_position
@export var brightness:CanvasModulate

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
var lastpos=0
var original_position=0;
var shake_timer=0;
var duration=0;
var intensity=0;
signal scrolled;
func shake(duration: float, intensity: float,position,maxval=MAX_SHAKE):
	if intensity>maxval: return;
	if abs(abs(position.y)-abs(position.y))>1000:return

	if intensity>MAX_SHAKE: return
	shake_timer = 0.0
	self.duration=duration;
	self.intensity=self.intensity+intensity
	
	pass	



	
func isOffCamera(position):

	var diff= abs(abs(position.y)-abs(global_position.y))
	return diff>1000
	
	pass;	
func _process(delta):
	if shake_timer < duration:
		var x_offset = randf_range(-intensity, intensity)
		var y_offset = randf_range(-intensity, intensity)
				
		offset.x =x_offset/zoom.x
		offset.y =y_offset/zoom.x
		duration=duration-1*delta
		if intensity>0:intensity=intensity-1*delta
		
	if tween!=null&&tween.is_running:
		scrolled.emit()
	
		
	
	lastpos=global_position.y	
	pass;
	
func _ready():
	
	Projectile.camera=self;
	Turret.camera=self;
	pass;
	
func changeBrightness():
	var v=thresholds.getDark(gameState.y)
	brightness.color=Color(v,v,v,255)
	v=thresholds.getGlow(gameState.y)
	env.environment.glow_intensity=v
	
	pass;
	
func _input(event):
	if event.is_action("left_click"):
		scrolled.emit()
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
			scrolled.emit()
		dragging = true
		position = (mouse_start_pos - event.position) / zoom + screen_start_position
	
	if event.is_action_pressed("scroll_up"):
		scrolled.emit()
		if Input.is_action_pressed("control"):
			zoom = Vector2(zoom.x + CAMERA_ZOOM, zoom.y + CAMERA_ZOOM)
		else:
			position -= Vector2(0, SCROLL_SPEED) / zoom
			
	if event.is_action_pressed("scroll_down"):
		scrolled.emit()
		if Input.is_action_pressed("control"):
			zoom = Vector2(zoom.x - CAMERA_ZOOM, zoom.y - CAMERA_ZOOM)
		else:
			position += Vector2(0, SCROLL_SPEED) / zoom
var tween			
func move_to(position: Vector2, done: Callable):
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", position, Stats.CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): done.call())
