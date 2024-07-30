extends TurretBaseMod
class_name FrozenKillMod

func on_hit(p:Projectile,m:Monster):
	
	var frost=FrostDebuff.new(FROZEN_DURATION*pow(FROZEN_SCALING,level),
	associate
	,level,
	999999)
	frost.register(m)
	super(p,m)
	pass
