extends BaseEntity
class_name FireTrail
signal done
var bullet
var origin
var decay=1
var decaying=false;
static var cache=[]	
var line:Line2D
@export var gradient:Gradient
var default_gradient
var str=1
var mod:TurretBaseMod

func _ready():
	get_tree().create_timer(decay).timeout.connect(func():decaying=true)
	var arr=$trail.emission_points
	arr.append(Vector2(50,50))
	$trail.emission_points=arr
	
	
	pass;
func _notification(what):
	if what==NOTIFICATION_PREDELETE:
		line.queue_free()	
		
func on_cell_traversal():
	if bullet==null:
		return
	GameState.collisionReference.register_entity_at_position(self,bullet.get_global())
	pass;		
func _process(delta):
	if decay<=0:
		remove()
		return
	if bullet!=null:
		if !bullet.shot:
			bullet=null
			var p=line.points
			p.reverse()
			line.points=p
			return
		line.add_point(bullet.get_global())
		var arr=$trail.emission_points
		var point=bullet.get_global()
		arr.push_back(point)
		$trail.emission_points=arr	
		
	elif decaying:
	
		decay-=delta/10
		var arr=$trail.emission_points
		if !arr.is_empty():
			arr.resize(arr.size()-1)
			$trail.emission_points=arr
		line.gradient=gradient
		for point in range(5):
			gradient.set_offset(point,lerp(0.0,default_gradient.get_offset(point),decay))
		var off=gradient.get_offset(4)
		
		var remove_pos=lerp(origin,get_global(),off)
		if off<0.01:
			remove()
		if GameState.collisionReference.getMapPositionNormalised(remove_pos)!=GameState.collisionReference.getMapPositionNormalised(previous_pos):	
			GameState.gameState.collisionReference.remove_entity_from_position(self,remove_pos)
			previous_pos=remove_pos
				
	pass;
var previous_pos=Vector2(0,0)	
func initialise(mod):
	bullet=null
	self.mod=mod
	decay=1
	if line==null:
		line=Line2D.new()
		GameState.gameState.add_child(line)
	else:
		line.clear_points()	
	if default_gradient==null:
		default_gradient=gradient.duplicate()	
	gradient=default_gradient	
	line.gradient=gradient
	line.width=4	
	origin=null
	decaying=false
	
	pass;
func remove():
	GameState.collisionReference.remove_entity(self)
	done.emit()
	cache_fire(self)
	bullet=null
	$trail.emission_points=[]
	if is_instance_valid(line):
		line.clear_points()
	pass
func trigger_minion(monster:Monster):
	if util.valid(mod):
		mod.trigger_minion(monster)
	pass;
func trigger_projectile(projectile:Projectile):
	if util.valid(mod):mod.trigger_projectile()
	pass;	
func register_bullet(projectile:Projectile):
	bullet=projectile
	origin=projectile.get_global()
	
	pass;	
static func get_trail():
	var fire
	if cache.is_empty():
		fire=_load_trail()
	else:
		fire=cache.pop_back()
	return fire	

static func _load_trail():
	return 	load("res://effects/fire_trail.tscn").instantiate()	
static func cache_fire(fire):
	var parent=fire.get_parent()
	if parent!=null:
		parent.remove_child(fire)
	cache.push_back(fire)
	pass;	
