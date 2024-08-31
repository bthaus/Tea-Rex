extends ProductionBaseMod
class_name TrapdoorProductionMod

func get_timeout():
	return 10
	pass;
func instantiate_produce():
	return load("res://TurretMods/production_mods/mod_produce/Trapdoor_mod_produce.tscn").instantiate()
	pass;	
