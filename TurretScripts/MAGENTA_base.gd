extends TurretCore
class_name MagentaCore


func on_target_found(monster:Monster):
	ref_proj=shoot(monster)
	super(monster)
	pass;
	
func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		if is_instance_valid(ref_proj):ref_proj.delete()	
func on_target_lost():
	ref_proj.remove()
	super()
	pass;


func attack(delta):
	#if target==null:
		#projectile.remove_target()
	if target!=null:
		if not onCooldown:
			ref_proj.hitEnemy(target,true)
			startCooldown(cooldown * cooldownfactor)
	pass;
