extends Card
class_name BlockCard
var block:Block;

var cardName;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
static var showRotateTut=true
static func create(gameState:GameState,block=-1):
	var card=load("res://Cards/block_card.tscn").instantiate() as BlockCard;
	card.state=gameState;
	if block is Block:
		card.block=block
	else:
		card.block=util.getRandomBlock(1,gameState);
		
	return card;
func select(done:Callable):
	
	if state.phase==Stats.GamePhase.BATTLE:
		done.call(false);
		return
	state.gameBoard.select_block(block,done)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
