extends TurretBaseMod
class_name FrostAmmunitionMod

func on_hit(p:Projectile,m:Monster):
	if !util.valid(m):return
	var frost=FrostDebuff.new(FROST_AMMO_SLOW_DURATION*pow(FROST_AMMO_SCALING,level),
	associate
	,level,
	FROST_AMMO_SLOW_AMOUNT*pow(FROST_AMMO_SCALING,level))
	frost.register(m)
	super(p,m)
	pass
