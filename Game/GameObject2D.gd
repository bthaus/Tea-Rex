extends Node2D
class_name GameObject2D

var debuffs={}

func apply_debuffs(delta):
	for d in debuffs:
		if debuffs[d].is_empty():continue
		debuffs[d][0].on_tick()
		#thats just a stub for properly removing debuffs from the array
		if debuffs[d][0].to_remove:
			debuffs[d][0].remove()
	pass;

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


