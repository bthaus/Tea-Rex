extends CardCore
class_name SpecialCardBase
@export var instant = false;

enum Cardname{FIREBALL,DUMMY}

var cardName:Cardname
var selected = false;
var active = false;

static var ignoreNextClick = false;
static var rng = RandomNumberGenerator.new()
var preview

func select(done: Callable):
	self.done = done;
	if !isPhaseValid():
		interrupt()
		return
	super(done)
	if instant:
		cast()
		return ;
		
	selected = true;
	set_preview()
	pass ;
	
func set_preview():
	preview=CardCoreFactory.get_default_preview()
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


func _trigger_turn_effect():
	super()
	pass;

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
	super()
	selected = false;
	done.call(false)
	if util.valid(self.preview):
		self.preview.visible=false;
	pass ;
