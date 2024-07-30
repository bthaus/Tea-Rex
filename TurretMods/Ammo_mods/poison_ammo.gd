extends TurretBaseMod
class_name PoisonAmmunitionMod

func on_hit(p:Projectile,m:Monster):
	if !util.valid(m):return
	
	var poison=PoisonDebuff.new(POISON_AMMO_FIRE_DURATION*pow(POISON_AMMO_SCALING,level),
	associate
	,level,
	POISON_AMMO_TICK_DAMAGE*pow(POISON_AMMO_SCALING,level),
	POISON_AMMO_PROPAGATION_TIME*pow(POISON_AMMO_SCALING,level))
	poison.register(m)
	super(p,m)
	pass;

