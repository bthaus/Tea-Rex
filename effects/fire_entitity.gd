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
	print("registered at: "+str(bullet.get_reference()))	
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
	
		decay-=delta/200
		var arr=$trail.emission_points
		if arr.is_empty():return
		
		arr.resize(arr.size()-1)
		$trail.emission_points=arr
		line.gradient=gradient
		for point in range(5):
			gradient.set_offset(point,lerp(0.0,gradient.get_offset(point),decay))
		var off=gradient.get_offset(3)
		var remove_pos=lerp(origin,get_global(),off)
		if off<0.01:
			remove()
		GameState.gameState.collisionReference.remove_entity_from_position(self,remove_pos)
	
				
	pass;
func initialise():
	bullet=null
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
	line.clear_points()
	pass
func trigger_minion(monster:Monster):
	print("hitt fire")
	pass;
func trigger_projectile(projectile:Projectile):
	print("trigger projectile")
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
	return 	load("res://effects/cell_fire.tscn").instantiate()	
static func cache_fire(fire):
	fire.get_parent().remove_child(fire)
	cache.push_back(fire)
	pass;	
