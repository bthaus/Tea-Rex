extends GameObject2D
class_name BaseEntity

var tile_id
var map_layer
var map_position
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body
	
func place_on_gameboard(gameboard:GameBoard):
	util.p("unimplemented call place on gameboard")
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
