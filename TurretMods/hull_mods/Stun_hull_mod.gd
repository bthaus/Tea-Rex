extends HullBaseMod
class_name StunHullMod

func get_timeout():
	return super()*3
func get_type():
	return StunTowerDebuff
