extends MonsterCore
class_name MainAttraction
func on_cell_traversal():
	var turrets=GameState.collisionReference.get_covering_turrets_from_position(get_global())
	for t in turrets:
		if t.base.target!=holder:
			t.base.target_override(holder)
	pass;
