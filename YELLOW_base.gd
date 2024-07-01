extends TurretCore
class_name YellowTurretCore


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	if target != null: targetposition = target.global_position;
	if buildup == 0: return ;
	if targetposition == null: return ;
	if buildup < 0: buildup = 0
	
	direction = (targetposition - holder.global_position).normalized();
	#$Barrel.rotation=direction.angle() + PI / 2.0;
	var color = Color(1, 1, 1, 1 * buildup)
	var thickness = 1 * buildup;
	for b in getBarrels():
		var bgp = b.get_child(0).global_position;
		var bp = b.get_child(0).position;
		draw_line((b.position + bp).rotated(rotation), -(holder.global_position - (targetposition) - (b.position - bp).rotated(rotation)), color, thickness, true)
		draw_line((b.position + bp).rotated(rotation), -(holder.global_position - (targetposition) - (b.position - bp).rotated(rotation)), color, thickness, true)
	pass;
func attack(delta):
	buildup = buildup - 4 * delta;
	if target != null:
		if !onCooldown:
				#if camera != null:
					#var mod = camera.zoom.y - 3;
					#$AudioStreamPlayer2D.volume_db = 10 + mod * 10
					
				#if !$AudioStreamPlayer2D.playing&&sounds<25:
				#$AudioStreamPlayer2D.play()
				projectile.hitEnemy(target)
				buildup = 1;
				queue_redraw()
				startCooldown(cooldown * cooldownfactor)
				onCooldown = true;
	if buildup > 0 and target == null:
			buildup = buildup - 2 * delta;
		
	queue_redraw()
	pass;
func getTarget():
	if minions.get_child_count() > 0:
		target = minions.get_children().pick_random()

	pass;
func showRangeOutline():
	return	
	
func checkTarget():
	return	
func setupCollision(clearing):
	return		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
