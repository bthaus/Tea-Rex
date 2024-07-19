extends Projectile
class_name MagentaProjectile

var origin:Node2D
var line:Line2D
var _is_duplicate=false;
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

func hitEnemy(enemy):
	if _is_duplicate:
		target=enemy
		buildup=1
	if !associate.onCooldown:
		penetrations = penetrations - 1;
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
func move(delta):
	fade(delta)	
	if origin==null or !is_instance_valid(origin) or target==null or !is_instance_valid(target):return
	buildup=buildup+delta*2
	line.clear_points()
	line.add_point(origin.global_position)
	var pointx=remap(buildup,0,1,origin.global_position.x,target.global_position.x)
	var pointy=remap(buildup,0,1,origin.global_position.y,target.global_position.y)
	var p=Vector2(pointx,pointy)
	line.add_point(p)
	
	global_position=p
	pass;

	
func fade(delta):
	if target==null:
		buildup=buildup-delta*2
		_toggle_emission(false)
	line.default_color=Color(1,1,1,buildup)
		
	pass;	
var children_lasers=[]	
func duplicate_and_shoot(angle,origin=null)->Projectile:
	var p=super(angle)
	if origin==null:
		origin=self
	p.origin=origin
	children_lasers.append(p)
	return p
func _shoot_duplicate(projectile,angle):
	var ms=associate.return_targets(projectile.target)
	if ms.size()<3:
		ms=gamestate.collisionReference.getMinionsAroundPosition(ms[0].global_position)
	ms.erase(projectile.target)	
	#var node=Node2D.new()
	#var off=Vector2(associate.turretRange* GameboardConstants.TILE_SIZE,0)
	#off=util.rotate_vector(off,angle)
	#node.position=origin.global_position+off
	#projectile.origin.add_child(node)
	projectile.shoot(ms.pick_random())
	
	pass;	



