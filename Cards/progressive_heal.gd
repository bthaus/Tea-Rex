extends SpecialCardBase
class_name ProgressiveHeal
@export var heal_amount:int=25
@export var turn_heal_amount:int=5


func _trigger_play_effect():
	GameState.gameState.changeHealth(heal_amount)
	pass;
func _trigger_turn_effect():
	GameState.gameState.changeHealth(turn_heal_amount)
	pass;
func on_discard():
	
	pass

# Called when the node enters the scene tree for the first time.
