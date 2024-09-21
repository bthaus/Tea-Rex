extends ProductionBaseMod
class_name MineProductionMod

func get_timeout():
	return 3
	pass;
func instantiate_produce():
	return load("res://TurretMods/production_mods/mod_produce/MineModProduce.tscn").instantiate()
