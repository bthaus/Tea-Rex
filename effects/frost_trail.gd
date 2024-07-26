extends FireTrail
class_name FrostTrail

static var frost_cache=[]

func trigger_minion(monster:Monster):
	var frost=FrostDebuff.new(3,1,100)
	frost.register(monster)
	pass;
func trigger_projectile(projectile:Projectile):
	print("trigger frost")
	pass;	

static func get_trail(associate:TurretCore):
	var fire
	if frost_cache.is_empty():
		fire=_load_trail()
	else:
		fire=frost_cache.pop_back()	
	fire.associate=associate	
	return fire	

static func _load_trail():
	return 	load("res://effects/frost_trail.tscn").instantiate()	
