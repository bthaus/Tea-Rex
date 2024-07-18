extends TurretCore
class_name YellowTurretCore


func getTarget():
	if minions.get_child_count() > 0:
		target = minions.get_children().pick_random()
	pass;


