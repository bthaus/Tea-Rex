extends TurretCore
class_name MagentaCore


func on_target_found(monster:Monster):
	projectile=shoot(monster)
	super(monster)
	pass;
	
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		projectile.line.queue_free()	
func on_target_lost():
	
	projectile.remove_target()
	super()
	pass;


func attack(delta):
	if target==null:
		projectile.remove_target()
	if target!=null:
		if not onCooldown:
			projectile.hitEnemy(target)
			startCooldown(cooldown * cooldownfactor)
	pass;
