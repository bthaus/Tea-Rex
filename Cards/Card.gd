extends Node2D
class_name Card


func select(done:Callable):
	
	pass;
static var counter=0;	
static func create(gameState:GameState):
	counter=counter+1;
	var btn=Button.new()
	btn.icon=load("res://Assets/Cards/cardBack.png")
	
	var card;
	if counter%2 == 0:
		card=SpecialCard.create(gameState)
		btn.text=Stats.SpecialCards.keys()[card.cardName-1];	
		
	else:
		card= BlockCard.create(gameState)
		
	
	btn.add_child(card)
	if card is BlockCard:
		var b=load("res://GameBoard/game_board.tscn").instantiate()
		btn.add_child(b)
		b.block_handler=BlockHandler.new(b.get_child(0))
		b._place_block(card.block,Vector2(0,0))
		b.scale=Vector2(0.5,0.5)
		b.position=Vector2(50,50)
	return btn
	
func played(interrupted:bool):
	if not interrupted:
		queue_free()
	pass;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
