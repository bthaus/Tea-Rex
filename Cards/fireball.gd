extends SpecialCardBase
class_name Fireball
@export var turn_player_damage:int=5
@export var damage:int=500
@export var range:int=2


func _trigger_play_effect():
	Explosion.create(GameplayConstants.DamageTypes.FIRE,damage,get_mouse_pos(),self,range)	
	pass;
func _trigger_turn_effect():
	GameState.gameState.changeHealth(-turn_player_damage)
	pass;
	
