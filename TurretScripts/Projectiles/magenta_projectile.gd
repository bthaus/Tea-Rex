extends Projectile
class_name MagentaProjectile


var start_emitter:GPUParticles2D
var end_emitter:GPUParticles2D
var beam_emitter:GPUParticles2D

var children_lasers=[]	
var ignore_position
var distance_travelled=Vector2(0,0)	
var origin:Node2D
var line:Line2D
var _is_duplicate=false;
var connected=false
	

var buildup:float=0.1:
	set(val):
		buildup=clamp(val,0,1)
		
func remove_target():
	if not shot:return
	
	remove()
	target=null
	for child in children_lasers:
		child.remove_target()
	pass;		
func on_creation():
	if line==null:
		line=Line2D.new()
		line.z_index=10
		line.default_color=Color(5,0.5,5)
		line.show()
		GameState.gameState.add_child(line)
	origin=associate
	process_mode=Node.PROCESS_MODE_ALWAYS
	children_lasers.clear()
	start_emitter=$fire
	end_emitter=$hit
	beam_emitter=$beam
	
	connected=false
	buildup=0.1
	ignore_position=Vector2(0,0)
	distance_travelled=Vector2(0,0)
	_is_duplicate=false
	pass;	
var last_hit_position=Vector2i(0,0)
func hitEnemy(enemy,from_turret=false):
	#connected turrets only hit their connected enemy
	if connected and not from_turret:
		return
	#only hit without connection once per tile	
	if not from_turret:
		var curry=gamestate.board.local_to_map(global_position)
		if curry==last_hit_position:
			return
		else:
			last_hit_position=curry	
	#if a duplicate hits an enemy, it checks if its on the same pos at it was created, 
	#and connects to that target. 	
	if _is_duplicate:
		if ignore_position==GameState.board.local_to_map(global_position):return
		target=enemy
		connected=true
		_is_duplicate=false
		buildup=1
	#hits all offspring of the laser
	if from_turret:	
		for child in children_lasers:
			if child.buildup==1:
				child.hitEnemy(child.target,true)
	#initial beam, connects only to target
	if enemy==target:
		connected=true	
	#fallback safety
	if target==null:
		return	
	#hit logic		
	penetrations = penetrations - 1;
	apply_damage_stack(enemy)
	var killed=enemy.hit(type, damage)
	if killed:remove()
	if associate != null: associate.on_hit(enemy,damage,type,killed,self)
	if from_turret:associate.startCooldown()
	pass;
func shoot(target):
	super(target)
	line.show()
	pass;

func delete():
	for child in children_lasers:
		child.delete()	
	if is_instance_valid(line):
		line.queue_free()
	if is_instance_valid(self):queue_free()
	pass;

func move(delta):
	fade(delta)	
	if target!=null:check_collision()
	if origin==null or !is_instance_valid(origin) or target==null or !is_instance_valid(target):return
	
	buildup=buildup+delta*2
	#if direction would be updated if duplicate and not connected it wouldnt do anything (direction==0,0)
	if not _is_duplicate:
		direction = (target.global_position - origin.global_position).normalized()
	#travel across the originally calculated distance	
	if _is_duplicate:
		distance_travelled=distance_travelled+super(delta)
	#move towards target if not duplicate	
	elif target!=null:
		var distance=delta * speed
		global_position=global_position.move_toward(target.global_position,distance)
		distance_travelled=distance_travelled+distance*direction
	#fallback. shouldnt be called
	else:
		distance_travelled=distance_travelled+super(delta)
	if not connected:
		if global_position==target.global_position:
			hitEnemy(target,false)	
	start_emitter.global_position=origin.global_position
	start_emitter.process_material.direction=Vector3(direction.x,direction.y,0)
	end_emitter.emitting=connected
	end_emitter.global_position=global_position
	
	start_emitter.process_material.direction=Vector3(direction.x*-1,direction.y*-1,0)
	beam_emitter.process_material.emission_box_extents.x=(origin.global_position-global_position).length()*0.5
	beam_emitter.global_position=lerp(global_position,origin.global_position,0.5)
	beam_emitter.global_rotation_degrees= rad_to_deg((origin.global_position-global_position).angle() + PI / 2.0)+90
	
	beam_emitter.amount_ratio=2*buildup
	if _is_duplicate and distance_travelled.length_squared()>associate.trueRangeSquared and not connected:
		remove()
			
		
	draw_points(origin.global_position,global_position,delta)
	
	pass;

	
func check_collision():
	if ghost_projectile:
		return
	if !util.valid(origin):remove()	
	var start=origin.global_position
	while start!=global_position:
		start=start.move_toward(global_position,10)
		if gamestate.collisionReference.hit_wall(gamestate.board.local_to_map(start)):
			remove()
	pass;
	
func draw_points(a,b,delta):
	line.clear_points()
	line.add_point(a)
	line.end_cap_mode=Line2D.LINE_CAP_ROUND
	line.add_point(b)
	pass;	
func apply_damage_stack(enemy: Monster):
	var temp = false;
	for a in enemy.get_children():
		if a is DamageStacker:
			temp = true;
			damage = damage + a.hit()
	if !temp:
		enemy.add_child(DamageStacker.new());
	pass
	
func fade(delta):
	if target==null:
		#line.width=lerp(0,12,buildup)
		buildup=buildup-delta*2
		_toggle_emission(false)
	if shot and buildup<0.1:
		super.remove()
	line.default_color.a=buildup
	line.width=lerp(0,12,buildup)	
	pass;	

func call_on_projectile_removed():
	
	pass;
func duplicate_and_shoot(angle,origin=null)->Projectile:
	var p=super(angle)
	if origin==null:
		p.origin=self
	else:
		p.origin=origin	
	p.ignore_position=GameState.board.local_to_map(global_position)	
	p._is_duplicate=true	
	p.buildup=1
	children_lasers.append(p)
	return p
func remove():
	target=null
	if !is_instance_valid(self) or self==null:return
	if !is_instance_valid(associate) or associate==null:return
	associate.on_projectile_removed(self)
	for child in children_lasers:
		child.remove()
	children_lasers.clear()	
	if not _is_duplicate:
		associate.target=null	
		#associate.on_target_lost()
func _remove_from_tree():
	line.hide()
	super()
	pass;	

func _toggle_emission(b):
	start_emitter.emitting=b
	end_emitter.emitting=b
	beam_emitter.emitting=b
	pass;	
#func _shoot_duplicate(projectile,angle):
	##var ms=associate.return_targets(projectile.target)
	##if ms.size()<3:
		##ms=gamestate.collisionReference.getMinionsAroundPosition(ms[0].global_position)
	##ms.erase(projectile.target)	
	###var node=Node2D.new()
	##var off=Vector2(associate.turretRange* GameboardConstants.TILE_SIZE,0)
	##off=util.rotate_vector(off,angle)
	##node.position=origin.global_position+off
	##projectile.origin.add_child(node)
	#projectile.line.show()
	#projectile.direction=util.rotate_vector(direction,angle)
	#projectile.global_rotation = projectile.direction.angle() + PI / 2.0
	#projectile.shot=true
	#pass;	



