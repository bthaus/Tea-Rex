extends ItemList
@export var gamestate:GameState

# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate.level_up.connect(refreshlist)
	pass # Replace with function body.

func refreshlist():
	
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
