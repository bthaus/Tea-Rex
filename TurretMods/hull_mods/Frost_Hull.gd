extends HullBaseMod
class_name FrostHullMod
#var shield
func get_timeout():
	return super()*3
func get_type():
	return FreezeTowerDebuff

#func remove():
	#util.erase(shield)
	#super()
	#pass;
#func on_level_up(lvl):
	#util.erase(shield)
	#var shield=ShieldFactory.get_shield_texture(ShieldFactory.ShieldType.energy,level)
	#self.shield=shield
	#associate.add_child(shield)
	#pass;	
#func initialise(core:TurretCore):
	#var shield=ShieldFactory.get_shield_texture(ShieldFactory.ShieldType.energy,level)
	#self.shield=shield
	#core.add_child(shield)
	#super(core)
	#pass;	
