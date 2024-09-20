extends Sprite2D
class_name SpecialCardBase
var done:Callable
enum Cardname{Fireball}
var gameState
@export var phase:GameState.GamePhase
@export var instant = false;
@export var soundeffect:AudioStream

var cardName:Cardname
var selected = false;
var active = false;

static var ignoreNextClick = false;
static var rng = RandomNumberGenerator.new()
var preview
func _ready() -> void:
	gameState=GameState.gameState
	GameState.gameState.start_build_phase.connect(_trigger_turn_effect)
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
	preview.reparent(self)
	pass;
func cast():
	if Card.contemplatingInterrupt and not instant:
		interrupt()
		return ;
	_trigger_play_effect()
	done.call(true)
	
	pass ;
func _trigger_play_effect():
	
	pass;
func _trigger_turn_effect():
	
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

func interrupt():
	selected = false;
	done.call(false)
	pass ;

func isPhaseValid() -> bool:
	return gameState.phase == phase||phase == GameState.GamePhase.BOTH||gameState.phase == GameState.GamePhase.BOTH
