extends ProductionBaseMod
class_name TrapdoorMod

func get_timeout():
	return 10
func instantiate_produce():
	return load("res://TurretMods/production_mods/mod_produce/TrapdoorModProduce.tscn").instantiate()
	pass;	
