extends CardCore
class_name BlockCard
var block:Block;
var state
var cardName;
var preview

static var showRotateTut=true

func initialise(block):
	state=GameState.gameState
	var color=block.color;
	self.block=block
	preview=load("res://Cards/block_preview.tscn").instantiate()
	preview.set_block(block, true)
	preview.scale=Vector2(0.3,0.3)
	add_child(preview)
	
func select(done:Callable):
	if state.phase==GameState.GamePhase.BATTLE:
		done.call(false);
		return
	state.gameBoard.select_block(block,done)
	super(done)
	pass;

func interrupt():
	GameState.gameState.gameBoard.action=GameBoard.BoardAction.NONE
	GameState.gameState.gameBoard._action_finished(false)
	super()
	pass;
func on_discard(odd:Callable):
	preview.clear_preview();
	if discard_effect!=null:
		material=discard_effect
		$AnimationPlayer.play(&'dissolve')
		
	super(odd)
	pass;
