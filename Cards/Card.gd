extends GameObject2D
class_name Card
var card;
var state:GameState;
static var isCardSelected=false;
static var selectedCard;
signal mouseIn
signal mouseOut

var originalPosition;
var originalZ=0;

	
static var counter=0;
signal finished(card)

func setCard(c):
	card=c;
	add_child(c)
	pass;
static func create(gameState:GameState):
	counter=counter+1;
	var c=load("res://Cards/card.tscn").instantiate() as Card
	var btn=c.get_child(0) as Button
	var created_card=gameState.get_next_card()
	c.setCard(created_card)
	return c

func played(success:bool):
	if not success and isCardSelected:
		_on_disable_button_pressed()
	if not success:return
	if card is BlockCard:
		card.preview.clear_preview();
		card.preview.queue_free()
	queue_free()
	finished.emit(self)
		
	pass;
# Called when the node enters the scene tree for the first time.
func _ready():
	originalPosition=global_position
	pass # Replace with function body.




func trigger_turn_effect():
	var tw=create_tween()
	tw.tween_property(self,"position",position-Vector2(0,10),0.4)
	tw.tween_property(self,"position",position,0.4)
	card._trigger_turn_effect()
	pass;
func discard() -> void:
	interrupt_Card()
	if card.discardable:
		card.on_discard()
		queue_free()
	pass # Replace with function body.
#################select logic##########################

func _on_button_pressed():
	select(played)
	pass # Replace with function body.
func select(done:Callable):
	if ignore_next_click:
		ignore_next_click=false;
		return
	if dragged:return
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY).timeout.connect(delayedSelect.bind(done))
	pass;
func delayedSelect(done):
	if util.valid(selectedCard) and isCardSelected&&selectedCard!=self:
		selectedCard.card.interrupt()
		selectedCard=self;	
	
	toggle_put_back(true)
	isCardSelected=true;
	selectedCard=self;
	scale=Vector2(1.3,1.3)
	
	z_index=2000
	card.select(done)
	pass;
		
###########################interrup logic###########################
func _on_disable_button_pressed():
	scale=Vector2(1,1)
	z_index=originalZ
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY+0.1).timeout.connect(func():$Button.mouse_filter=0)
	toggle_put_back(false)
	interrupt_Card()
	pass # Replace with function body.
func toggle_put_back(active:bool):
	
	$PutBack/DisableCard.visible=active
	var filter
	if active:
		filter=0
	else:
		filter=2	
	$PutBack.mouse_filter=filter
	
	pass;	

func interrupt_Card():
	if !util.valid(selectedCard):return
	isCardSelected=false;	
	selectedCard.card.interrupt()
	selectedCard=null;	
	pass;
		
##############drag logic################
var dragged=false;
var try_drag=false;
var drag_confirmed=false;
const drag_recognition_time=0.1
static var ignore_next_click=false;
func _input(event: InputEvent) -> void:
	if not dragged:return;
	if event.is_action_released(&"left_click"):
		if drag_confirmed:
			card.on_drop()
			drag_confirmed=false;
		
		try_drag=false;
		dragged=false;
		if TrashCan.dumping:
			discard()
		GameState.gameState.hand.reorder()
		
	pass;
func _on_button_button_down() -> void:
	dragged=true;
	try_drag=true;
	card.on_click()
	get_tree().create_timer(drag_recognition_time).timeout.connect(_init_drag)
	pass # Replace with function body.


func _init_drag():
	if not try_drag: return
	drag_confirmed=true;
	ignore_next_click=true;
	pass
func _process(delta: float) -> void:
	if not dragged:return
	global_position=get_global_mouse_position()
	pass;

	
#################hover events	##########################
func _on_button_mouse_entered():
	originalZ=z_index;
	z_index=2000
	
	var tween = create_tween()
	if not dragged:
		tween.tween_property(self, "global_position", originalPosition+Vector2(0, -25), 0.5)
		card.on_hover()
	pass # Replace with function body.

func _on_button_mouse_exited():
	if selectedCard!=self:
		z_index=originalZ
		
	var tween = create_tween()
	if not dragged:
		tween.tween_property(self, "global_position", originalPosition, 0.5)
		card.on_unhover()
	mouseOut.emit()
	pass # Replace with function body.
	
############################ignore click logic##############################	
#contemplating interruipts are called on the putback button hover events, because they are only active if the card is selected
static var contemplatingInterrupt=false;
static var hoveredCard=null

func _on_disable_button_mouse_entered():
	hoveredCard=self
	contemplatingInterrupt=true;
	pass # Replace with function body.
	
func _on_disable_button_mouse_exited():
	if hoveredCard==self:
		hoveredCard==null;
		contemplatingInterrupt=false;	
	if hoveredCard==null:
		contemplatingInterrupt=false;	
	pass # Replace with function body.
