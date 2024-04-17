extends Node2D
class_name Card
var card;
static var isCardSelected=false;
func select(done:Callable):
	if isCardSelected:
		return;
	isCardSelected=true;
	card.select(done)
	scale=Vector2(1.3,1.3)
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
	

	if c.card is SpecialCard:
		c.get_child(1).text=Stats.getStringFromSpecialCardEnum(c.card.cardName);
		c.get_child(1).visible=true;
	if c.card is BlockCard:
		var b=load("res://GameBoard/game_board.tscn").instantiate()
		btn.add_child(b)
		b.block_handler=BlockHandler.new(b.get_child(0))
		b._place_block(c.card.block,Vector2(0,0))
		b._spawn_turrets()
		b.scale=Vector2(0.5,0.5)
		b.position=Vector2(50,70)
	return c
	
func played(interrupted:bool):
	scale=Vector2(1,1)
	isCardSelected=false;
	if  interrupted:
		queue_free()
		finished.emit(self)
		
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
