extends TurretBaseMod
class_name FireAmmunitionMod

func on_hit(p:Projectile,m:Monster):
	if !util.valid(m):return
	var fire=FireDebuff.new(FIRE_AMMO_FIRE_DURATION*pow(FIRE_AMMO_SCALING,level),
	associate
	,level,
	FIRE_AMMO_TICK_DAMAGE*pow(FIRE_AMMO_SCALING,level))
	fire.register(m)
	super(p,m)
	pass;

