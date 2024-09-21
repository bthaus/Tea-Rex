extends GameObject2D
class_name Card
var card;
var state:GameState;
static var isCardSelected=false;
static var selectedCard;
signal mouseIn
signal mouseOut

func select(done:Callable):
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY).timeout.connect(delayedSelect.bind(done))
	pass;
func delayedSelect(done):
	if util.valid(selectedCard) and isCardSelected&&selectedCard!=self:
		
		if (selectedCard.card!=null)&&(selectedCard.card is BlockCard):
			GameState.gameState.gameBoard._action_finished(false)
			selectedCard=self;
		elif (selectedCard.card!=null)&&(selectedCard.card is SpecialCardBase):
			selectedCard.card.interrupt()
			selectedCard=self;	
	
	$PutBack/DisableCard.show()
	$PutBack/Label.show()
	$PutBack.mouse_filter=0;
	$Discard/DisableCard.show()
	$Discard/Label.show()
	$Discard.mouse_filter=0
	$Button.mouse_filter=2;	
	
	isCardSelected=true;
	selectedCard=self;
	scale=Vector2(1.3,1.3)
	
	z_index=2000
	card.select(done)
	
	pass;	
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

func _on_button_pressed():
	select(played)
	pass # Replace with function body.

var originalPosition;
var originalZ=0;
func _on_button_mouse_entered():
	originalZ=z_index;
	z_index=2000
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition+Vector2(0, -25), 0.5)
	pass # Replace with function body.


func _on_button_mouse_exited():
	if selectedCard!=self:
		z_index=originalZ
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition, 0.5)
	mouseOut.emit()
	pass # Replace with function body.


func _on_disable_button_pressed():
	scale=Vector2(1,1)
	z_index=originalZ
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY+0.1).timeout.connect(func():$Button.mouse_filter=0)
	$PutBack.mouse_filter=2
	$PutBack/DisableCard.hide()
	$PutBack/Label.hide()
	$Discard/DisableCard.hide()
	$Discard/Label.hide()
	$Discard.mouse_filter=2
	interrupt_Card()
	
	pass # Replace with function body.

static var contemplatingInterrupt=false;
static var hoveredCard=null
func _on_disable_button_mouse_entered():
	hoveredCard=self
	contemplatingInterrupt=true;
	
	pass # Replace with function body.

func interrupt_Card():
	if !util.valid(selectedCard):return
	isCardSelected=false;	
	selectedCard.card.interrupt()
	selectedCard=null;	
	pass;
func _on_disable_button_mouse_exited():
	if hoveredCard==self:
		hoveredCard==null;
		contemplatingInterrupt=false;	
	if hoveredCard==null:
		contemplatingInterrupt=false;	
	
		
	pass # Replace with function body.

func trigger_turn_effect():
	var tw=create_tween()
	tw.tween_property(self,"position.y",position.y+10,0.2)
	tw.tween_property(self,"position.y",position.y-10,0.2)
	
	card.trigger_turn_effect()
	pass;
func _on_discard_pressed() -> void:
	interrupt_Card()
	if card.discardable:
		selectedCard.on_discard()
	queue_free()
	pass # Replace with function body.
