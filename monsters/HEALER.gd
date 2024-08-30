extends MonsterCore
@export var heal_amount:float=150
func do_special():
	var ms=GameState.collisionReference.getMinionsAroundPosition(global_position)
	ms.erase(holder)
	for m:Monster in ms:
		m.add_health(heal_amount)
	pass;
