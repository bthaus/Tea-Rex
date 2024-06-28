extends Base
class_name RedBase


# Called when the node enters the scene tree for the first time.
func _ready():
	after_built.append(showSaw)
	
	#$AudioStreamPlayer2D.finished.connect(func(): if inRange(): $AudioStreamPlayer2D.play)

	pass # Replace with function body.
func showSaw():
	projectile.scale = Vector2(1, 1)
	projectile.z_index = 0;
	projectile.visible = placed
	projectile.modulate = Color(1, 1, 1, 1)
	pass;	
func getReferences(cells):
	return collisionReference.getNeighbours(holder.global_position,cells);
	pass
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
			for cell in coveredCells:
				for e in cell:
					if !is_instance_valid(e): continue
					if e.hit(type, self.damage * stacks): addKill()
					addDamage(self.damage * stacks)
					projectile.playHitSound();
			startCooldown(cooldown * cooldownfactor)
		
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
