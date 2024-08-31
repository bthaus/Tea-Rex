extends ProductionBaseMod
class_name ChainProductionMod

func get_timeout():
	return 10
func instantiate_produce():
	return load("res://TurretMods/production_mods/mod_produce/chainModProduce.tscn").instantiate()
	pass;	
