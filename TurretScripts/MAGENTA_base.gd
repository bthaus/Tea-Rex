extends TurretCore
class_name MagentaCore

var active_rays=[]
func on_target_found(monster:Monster):
	var b=shoot(monster)
	if !active_rays.has(b):
		active_rays.append(b)
	pass;

func _notification(what):
	if (what == NOTIFICATION_PREDELETE):
		for b in active_rays:
			b.line.queue_free()
		
	

func get_projectile():
	return projectile
	


func attack(delta):
	for p in active_rays:
		if target==null and p!=projectile:
			p.remove_from_tree()
		p.fade(delta)
	if target!=null:
		if not onCooldown:
			for p in active_rays:
				p.hitEnemy(target)
			startCooldown(cooldown * cooldownfactor)
	pass;
