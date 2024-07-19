extends Projectile
class_name MagentaProjectile

var origin:Node2D
var line:Line2D
var _is_duplicate=false;
var connected=false
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
	line.z_index=50
	GameState.gameState.add_child(line)
	origin=associate
	process_mode=Node.PROCESS_MODE_ALWAYS
	children_lasers.clear()
	pass;	

func hitEnemy(enemy,from_turret=false):
	if _is_duplicate:
		if ignore_position==GameState.board.local_to_map(global_position):return
		target=enemy
		connected=true
		buildup=1
	if not from_turret and buildup==1: return
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
	associate.startCooldown(associate.cooldown*associate.cooldownfactor)
	pass;
func shoot(target):
	super(target)
	line.show()
	pass;
var cell_position=Vector2(0,0)
func delete():
	for child in children_lasers:
		child.delete()	
	line.queue_free()
	queue_free()
	pass;
var distance_travelled=Vector2(0,0)	
func move(delta):
	fade(delta)	
	if origin==null or !is_instance_valid(origin) or target==null or !is_instance_valid(target):return
	
	if connected:
		line.clear_points()
		line.add_point(origin.global_position)
		global_position=target.global_position
		line.add_point(global_position)
		return
		
	if not _is_duplicate and not connected:
		direction = (target.global_position - self.global_position).normalized()
		
	distance_travelled=distance_travelled+super(delta)
	
	if _is_duplicate and distance_travelled.length_squared()>associate.trueRangeSquared:
		target=null
	line.clear_points()
	line.add_point(global_position)	
	line.add_point(origin.global_position)	
	buildup=buildup+delta*2
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
		buildup=buildup-delta*2
		_toggle_emission(false)
	line.default_color=Color(1,1,1,buildup)
		
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



