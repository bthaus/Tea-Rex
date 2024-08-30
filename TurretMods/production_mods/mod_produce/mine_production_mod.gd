extends ProductionBaseMod
class_name MineProductionMod

func get_timeout():
	return 5
	pass;
func get_instance():
	return load("res://TurretMods/production_mods/mod_produce/MineModProduce.tscn").instantiate()

