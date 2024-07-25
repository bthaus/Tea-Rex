extends FireTrail
class_name FrostTrail



func trigger_minion(monster:Monster):
	print("hitt frost")
	pass;
func trigger_projectile(projectile:Projectile):
	print("trigger frost")
	pass;	

static func get_trail():
	var fire
	if cache.is_empty():
		fire=_load_trail()
	else:
		fire=cache.pop_back()	
	return fire	

static func _load_trail():
	return 	load("res://effects/frost_trail.tscn").instantiate()	
