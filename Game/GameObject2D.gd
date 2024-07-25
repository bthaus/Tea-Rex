extends Node2D
class_name GameObject2D

func get_global():
	return global_position
	pass;
func get_reference():
	return GameState.gameState.collisionReference.getMapPositionNormalised(get_global())
	pass;	
func get_map():
	return GameState.board.local_to_map(get_global())
	pass;	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
