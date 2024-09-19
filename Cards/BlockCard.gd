extends Sprite2D
class_name BlockCard
var block:Block;
var state
var cardName;
var preview
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
static var showRotateTut=true

func initialise(block):
	state=GameState.gameState
	var color=block.color;
	var ic=load("res://Assets/Cards/Testcard_"+util.getStringFromEnum(color).to_lower()+".png")
	texture=ic
	preview=load("res://Cards/block_preview.tscn").instantiate()
	preview.set_block(block, true)
	preview.position=Vector2(50,100)
	preview.scale=Vector2(0.3,0.3)
	add_child(preview)
	
func select(done:Callable):
	
	if state.phase==GameState.GamePhase.BATTLE:
		done.call(false);
		return
	state.gameBoard.select_block(block,done)
	pass;
