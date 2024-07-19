extends TurretCore
class_name RedTurretCore


# Called when the node enters the scene tree for the first time.

func after_built():
	super.after_built()
	showSaw()
	pass;	
func showSaw():
	projectile.global_position=holder.global_position
	projectile.scale = Vector2(1, 1)
	projectile.z_index =-1;
	projectile.visible = placed
	projectile.modulate = Color(1, 1, 1, 1)
	pass;	
func getReferences(cells):
	return collisionReference.getNeighbours(holder.global_position,cells);
	pass
func checkTarget():
	var pos=collisionReference.getMapPositionNormalised(target.global_position)
	if !referenceCells.has(pos):
		on_target_lost()
		target=null
	pass;	
func is_out_of_range(t):
	var pos=collisionReference.getMapPositionNormalised(target.global_position)
	return !referenceCells.has(pos)
	pass;	
func attack(delta):
	#check if blade should be rotating
	if buildup > 0&&projectile != null:
			projectile.rotate((180 * buildup * - 1) * 2 * delta);
	#if no target, slowly stop rotating the blade 	
	if target == null&&buildup > 0:
		buildup = buildup - 0.01 * delta;
	#if no target is present, stop the rest	
	if target == null: return
	#if target present and buildup is lower than maxrotation, start rotating		
	if buildup < 0.01:
		buildup = buildup + 0.01 * delta;
	#if not on cooldown, deal damage	
	if !onCooldown:
			var storepos=projectile.global_position
			for cell in coveredCells:
				var cell_triggered=false;
				for e in cell:
					if !is_instance_valid(e): continue
					var killed=e.hit(type, self.damage * stacks)
					if killed: addKill()
					
					if not cell_triggered:
						projectile.global_position=e.global_position
						on_hit(e,self.damage,type,killed,projectile)
						cell_triggered=true;
					addDamage(self.damage * stacks)
			projectile.global_position=storepos		
			startCooldown(cooldown * cooldownfactor)
		
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
