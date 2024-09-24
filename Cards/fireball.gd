extends SpecialCardBase
class_name Fireball
@export var turn_player_damage:int=5
@export var damage:int=500
@export var range:int=2


func on_click():
	$selected.emitting=true
	pass;	
func interrupt():
	$selected.emitting=false;
	super()
	pass;	
func on_drop():
	$selected.emitting=false;
	pass;	
func _trigger_play_effect():
	Explosion.create(GameplayConstants.DamageTypes.FIRE,damage,get_global_mouse_position(),self,range)	
	super()
	pass;
func _trigger_turn_effect():
	$turn_effect.emitting=true
	GameState.gameState.changeHealth(-turn_player_damage)
	super()
	pass;
	
