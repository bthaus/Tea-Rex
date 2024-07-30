extends TurretBaseMod
class_name FrostAmmunitionMod

func on_hit(p:Projectile,m:Monster):
	var frost=FrostDebuff.new(FROST_AMMO_SLOW_DURATION*FROST_AMMO_SCALING*level,
	associate
	,level,
	FROST_AMMO_SLOW_AMOUNT*FROST_TRAIL_SCALING*level)
	frost.register(m)
	super(p,m)
	pass
