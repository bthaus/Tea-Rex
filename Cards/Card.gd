extends Node2D
class_name Card
var card;
var state:GameState;
static var isCardSelected=false;
func select(done:Callable):
	if isCardSelected:
		return;
	if self is BlockCard and state.phase!=Stats.GamePhase.BUILD:
		return;
		
	
	isCardSelected=true;
	scale=Vector2(1.3,1.3)
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
	var c=load("res://card.tscn").instantiate() as Card
	var btn=c.get_child(0) as Button
	
	c.setCard(Stats.getRandomCard(gameState))
	c.state=gameState;

	if c.card is SpecialCard:
		c.get_child(1).text=Stats.getStringFromSpecialCardEnum(c.card.cardName);
		c.get_child(1).visible=true;
	if c.card is BlockCard:
		var preview=load("res://Cards/block_preview.tscn").instantiate()
		preview.set_block(c.card.block, true)
		preview.scale=Vector2(0.4,0.4)
		preview.position=Vector2(60,70)
		btn.add_child(preview)
	return c
	
func played(interrupted:bool):
	scale=Vector2(1,1)
	isCardSelected=false;
	if  interrupted:
		queue_free()
		finished.emit(self)
		GameSaver.saveGame(state)
		
	pass;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	select(played)
	pass # Replace with function body.
