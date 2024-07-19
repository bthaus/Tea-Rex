extends Projectile
class_name MagentaProjectile

var origin:Node2D
var line:Line2D
var buildup:float:
	set(val):
		buildup=clamp(val,0,1)
func remove_target():
	target=null
	pass;		
func on_creation():
	line=Line2D.new()
	line.z_index=50
	GameState.gameState.add_child(line)
	origin=associate
	process_mode=Node.PROCESS_MODE_ALWAYS
	pass;	

func hitEnemy(enemy):
	if buildup==1:
		penetrations = penetrations - 1;
		var killed=enemy.hit(type, damage)
		on_hit(enemy)
		if associate != null: associate.on_hit(enemy,damage,type,killed,self)
	pass;
func shoot(target):
	super(target)
	global_rotation=0
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
	line.default_color=Color(1,1,1,buildup)
		
	pass;	
var children_lasers=[]	
func duplicate_and_shoot(angle)->Projectile:
	
	var p=super(angle)
	p.origin=self
	children_lasers.append(p)
	return p
func _shoot_duplicate(projectile,angle):
	var ms=gamestate.collisionReference.getMinionsAroundPosition(projectile.global_position)
	ms=GameState.gameState.get_node("MinionHolder").get_children().pick_random()
	
	projectile.shoot(ms)
	
	pass;	



