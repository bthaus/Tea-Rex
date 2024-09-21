extends Sprite2D
class_name SpecialCardBase
var done:Callable
enum Cardname{Fireball}
var gameState
@export var phase:GameState.GamePhase
@export var instant = false;
@export var soundeffect:AudioStream
@export var discardable=true;
var player=AudioStreamPlayer.new()

var cardName:Cardname
var selected = false;
var active = false;

static var ignoreNextClick = false;
static var rng = RandomNumberGenerator.new()
var preview
func _ready() -> void:
	add_child(player)
	gameState=GameState.gameState
	pass;
func select(done: Callable):
	self.done = done;
	if !isPhaseValid():
		interrupt()
		return
	
	if instant:
		cast()
		return ;
		
	selected = true;
	set_preview()
	pass ;
func set_preview():
	preview=CardFactory.get_default_preview()
	if preview.get_parent()!=null:
		preview.reparent(self)
	else: add_child(preview)
	pass;
func cast():
	if Card.contemplatingInterrupt and not instant:
		interrupt()
		return ;
	player.stream=soundeffect
	
	player.play(0)
	reparentToState()
	hide()
	player.finished.connect(queue_free)
	remove_child(preview)	
	_trigger_play_effect()
	done.call(true)
	
	pass ;
func _trigger_play_effect():
	
	pass;
func _trigger_turn_effect():
	#player.stream=
	
	player.play(0)
	pass;
func on_discard():
	
	pass
func addKill():
	pass ;
func addDamage(damage):
	pass ;
func reparentToState():
	get_parent().remove_child(self)
	gameState.add_child(self)
	pass ;
func _input(event):
	if !selected:
		return ;
	preview.global_position=get_global_mouse_position()
	if ignoreNextClick:
		ignoreNextClick = false;
		return ;
	if event.is_action_released("left_click"):
		selected = false;
		cast()
	pass ;
func get_mouse_pos():
	var screen_mouse_position = get_viewport().get_mouse_position() # Get the mouse position on the screen
	# Convert it to world coordinates
	var mouse_pos = (get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()).affine_inverse() * screen_mouse_position
	return mouse_pos	

func interrupt():
	selected = false;
	done.call(false)
	self.preview.visible=false;
	pass ;

func isPhaseValid() -> bool:
	return gameState.phase == phase||phase == GameState.GamePhase.BOTH||gameState.phase == GameState.GamePhase.BOTH
