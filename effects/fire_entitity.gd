extends BaseEntity
class_name Fire
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
	#line.default_color=Color(0,0,0,0)
	default_gradient=gradient.duplicate()
	pass;
func _notification(what):
	if what==NOTIFICATION_PREDELETE:
		line.queue_free()	
func _process(delta):
	
	if bullet!=null:
		if !bullet.shot:
			bullet=null
			var p=line.points
			p.reverse()
			line.points=p
			return
			
		line.add_point(bullet.get_global())
		var arr=$trail.emission_points
		arr.push_back(bullet.get_global())
		$trail.emission_points=arr	
		
	elif decaying:
	
		decay-=delta/200
		var arr=$trail.emission_points
		arr.resize(arr.size()-1)
		$trail.emission_points=arr
		line.gradient=gradient
		for point in range(5):
			gradient.set_offset(point,lerp(0.0,gradient.get_offset(point),decay))
		
	if decay<=0:
		remove()			
	pass;
func initialise():
	bullet=null
	decay=1	
	if line==null:
		line=Line2D.new()
		GameState.gameState.add_child(line)
	else:
		line.clear_points()	
	line.gradient=default_gradient	
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
static func get_fire():
	var fire
	if cache.is_empty():
		fire=load("res://effects/cell_fire.tscn").instantiate()
	else:
		fire=cache.pop_back()
		
	return fire	
	pass;	
static func cache_fire(fire):
	fire.get_parent().remove_child(fire)
	cache.push_back(fire)
	pass;	
