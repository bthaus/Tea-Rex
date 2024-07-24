extends BaseEntity
class_name Fire
signal done
var bullet
var origin
var decay=2	
var decaying=false;
static var cache=[]	
var line:Line2D


func _ready():
	get_tree().create_timer(decay).timeout.connect(func():decaying=true)
	var arr=$fire.emission_points
	arr.append(Vector2(50,50))
	$fire.emission_points=arr
	pass;
	
func _process(delta):
	if decaying:
		decay-=delta
	if bullet.shot:	
		line.add_point(bullet.global_position)
		var arr=$fire.emission_points
		arr.push_back(bullet.global_position)
		$fire.emission_points=arr	
	if decaying and not bullet.shot:
		line.default_color.a=decay/5
		var arr=$fire.emission_points
		arr.resize(arr.size()-1)
		$fire.emission_points=arr		
	pass;
func initialise():
	bullet=null
	decay=5	
	if line==null:
		line=Line2D.new()
		GameState.gameState.add_child(line)
	else:
		line.clear()	
	line.width=4	
	origin=null
	decaying=false
	
	pass;
func remove():
	GameState.collisionReference.remove_entity(self)
	done.emit()
	cache_fire(self)
	pass
func trigger_minion(monster:Monster):
	print("hitt fire")
	pass;
func trigger_projectile(projectile:Projectile):
	print("trigger projectile")
	pass;	
func register_bullet(projectile:Projectile):
	bullet=projectile
	origin=projectile.global_position
	#bullet.removed.connsect(func():
		#var larr=line.points
		##larr.reverse()
		#line.points=larr
		#var arr=$fire.emission_points
		##arr.reverse()
		#$fire.emission_points=arr
		#)
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
