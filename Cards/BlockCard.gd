extends Card
class_name BlockCard
var block:Block;
var state:GameState;
var cardName;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func create(gameState:GameState):
	var card=load("res://Cards/BlockCard.gd").new() as BlockCard;
	card.state=gameState;
	card.block=Stats.new().getRandomBlock(1,gameState);

	return card;
func select(done:Callable):
	state.gameBoard.select_block(block,done)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
