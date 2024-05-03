extends Node2D
class_name Card
var card;
var state:GameState;
var description:String;
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
static func create(gameState:GameState,card=-1):
	counter=counter+1;
	var c=load("res://card.tscn").instantiate() as Card
	var btn=c.get_child(0) as Button
	if card is Card:
		c.setCard(card)
	else:	
		c.setCard(Stats.getRandomCard(gameState))
	c.state=gameState;

	if c.card is SpecialCard:
		c.get_child(1).text=Stats.getStringFromSpecialCardEnum(c.card.cardName);
		c.get_child(1).visible=true;
		var cardname=c.card.cardName;
		c.get_node("Button").icon=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardname)+"_preview.png")
		Stats.ge
	if c.card is BlockCard:
		var extension=c.card.block.extension;
		var color=c.card.block.color;
		#use this to change color/text of card
		var preview=load("res://Cards/block_preview.tscn").instantiate()
		
		preview.set_block(c.card.block, true)
		preview.scale=Vector2(0.3,0.3)
		preview.position=Vector2(50,100)
		btn.add_child(preview)
	return c
	
func played(interrupted:bool):
	scale=Vector2(1,1)
	isCardSelected=false;
	if  interrupted:
		queue_free()
		finished.emit(self)
		get_tree().create_timer(0.5).timeout.connect(GameSaver.saveGame.bind(state))
		
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
