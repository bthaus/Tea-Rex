extends Projectile
class_name MagentaProjectile

var origin:Node2D
var line:Line2D
var _is_duplicate=false;
var connected=false
var start_emitter:GPUParticles2D
var end_emitter:GPUParticles2D
var beam_emitter:GPUParticles2D
var buildup:float:
	set(val):
		buildup=clamp(val,0,1)
		
func remove_target():
	target=null
	for child in children_lasers:
		child.remove_target()
	pass;		
func on_creation():
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
	distance_travelled=Vector2(0,0)	
	pass;	

func hitEnemy(enemy,from_turret=false):
	print("hitting")
	if _is_duplicate:
		if ignore_position==GameState.board.local_to_map(global_position):return
		target=enemy
		connected=true
		_is_duplicate=false
		buildup=1
	
	if not from_turret and not connected:
		print("not connected yet, but hitting")
		var others=gamestate.collisionReference.get_monsters_at_pos(enemy.global_position)
		if others.has(target):
			enemy=target
			connected=true
	if connected and not from_turret:return
	
	for child in children_lasers:
		if child.buildup==1:
			child.hitEnemy(child.target,true)
	if enemy==target:
		connected=true	
	if target==null:
		return		
	penetrations = penetrations - 1;
	apply_damage_stack(enemy)
	var killed=enemy.hit(type, damage)
	on_hit(enemy)
	if associate != null: associate.on_hit(enemy,damage,type,killed,self)
	if from_turret:associate.startCooldown(associate.cooldown*associate.cooldownfactor)
	pass;
func shoot(target):
	super(target)
	line.show()
	pass;
var cell_position=Vector2(0,0)
func delete():
	for child in children_lasers:
		child.delete()	
	if is_instance_valid(line):
		line.queue_free()
	if is_instance_valid(self):queue_free()
	pass;
var distance_travelled=Vector2(0,0)	
var connection_mover_index:float=0:
	set(val):
		connection_mover_index=clamp(val,0,1)
var distance_from_target=Vector2(0,0)	
func move(delta):
	fade(delta)	
	if _is_duplicate:
		print("wtf")
	if origin==null or !is_instance_valid(origin) or target==null or !is_instance_valid(target):return
	buildup=buildup+delta*2
	if not _is_duplicate:direction = (origin.global_position-self.global_position).normalized();
	start_emitter.global_position=origin.global_position
	start_emitter.process_material.direction=Vector3(direction.x,direction.y,0)
	end_emitter.emitting=connected
	end_emitter.global_position=global_position
	
	start_emitter.process_material.direction=Vector3(direction.x*-1,direction.y*-1,0)
	beam_emitter.process_material.emission_box_extents.x=(origin.global_position-global_position).length()*0.5
	beam_emitter.global_position=lerp(global_position,origin.global_position,0.5)
	beam_emitter.global_rotation_degrees= rad_to_deg(direction.angle() + PI / 2.0)+90
	beam_emitter.amount_ratio=2*buildup
	
	if connected:
		global_position=lerp(global_position,target.global_position,connection_mover_index)
		connection_mover_index=connection_mover_index+delta*5
		draw_points(origin.global_position,global_position,delta)
		return	
	else:
		connection_mover_index=0	
	
		
	if not _is_duplicate and not connected:
		direction = (target.global_position - self.global_position).normalized()
	if _is_duplicate:
		distance_travelled=distance_travelled+super(delta)
	elif target!=null:
		var distance=delta * speed
		global_position=global_position.move_toward(target.global_position,distance)
		distance_travelled=distance_travelled+distance*direction
	else:
		distance_travelled=distance_travelled+super(delta)
		
	
	if _is_duplicate and distance_travelled.length_squared()>associate.trueRangeSquared:
		target=null
		
	draw_points(origin.global_position,global_position,delta)
	
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
	line.default_color.a=buildup
	line.width=lerp(0,12,buildup)	
	pass;	
var children_lasers=[]	
var ignore_position
func duplicate_and_shoot(angle,origin=null)->Projectile:
	var p=super(angle)
	if origin==null:
		origin=self
	p.ignore_position=GameState.board.local_to_map(global_position)	
	p._is_duplicate=true	
	p.origin=origin
	children_lasers.append(p)
	return p
func remove():
	target=null	

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



