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
#var damage;
#var range;
#var done: Callable;


#var tasks = []

static var ignoreNextClick = false;
static var rng = RandomNumberGenerator.new()

func select(done: Callable):
	self.done = done;
	if !isPhaseValid():
		interrupt()
		return
	
	if instant:
		cast()
		return ;
		
	selected = true;
	$Preview.visible = true;
	pass ;

func cast():
	if Card.contemplatingInterrupt and not instant:
		interrupt()
		return ;
	reparentToState()
	
	$EffectSound.play();
	
	pass ;

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
	if ignoreNextClick:
		ignoreNextClick = false;
		return ;
	if event.is_action_released("left_click"):
		selected = false;
		$Preview.visible = false;
		cast()
	pass ;

func interrupt():
	selected = false;
	done.call(false)
	pass ;

func isPhaseValid() -> bool:
	return gameState.phase == phase||phase == GameState.GamePhase.BOTH||gameState.phase == GameState.GamePhase.BOTH
