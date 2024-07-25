extends Node2D
class_name ModVisual
var on_projectile_node:Node2D
var on_idle_node:Node2D
var on_shoot_node:Node2D
var on_hit_node:Node2D
var on_hit_cache=[]
func _ready():
	on_projectile_node=get_node("on_projectile")
	on_idle_node=get_node("idle")
	on_shoot_node=get_node("on_shoot")
	on_hit_node=get_node("on_hit")
	
	for child in get_children():
		child.global_position=global_position
	
	pass;
func on_shoot(projectile:Projectile):
	prepare_projectile(projectile)
	if on_shoot_node!=null:
		on_shoot_node.restart()
		on_shoot_node.emitting=true
		var directoin=Vector3(projectile.direction.x,projectile.direction.y,0)
		on_shoot_node.process_material.direction=directoin	
	if projectile.has_method("_toggle_emission") and on_projectile_node!=null:
		projectile._toggle_emission(true)
	pass;	
# Called when the node enters the scene tree for the first time.
func prepare_projectile(projectile:Projectile):
	if on_projectile_node!=null:
		projectile.add_emitter(on_projectile_node.duplicate())
		
		
		
	pass;
func on_remove(projectile:Projectile):
	
	if projectile.has_method("_toggle_emission")and on_projectile_node!=null:
		projectile._toggle_emission(false)
	on_hit(projectile)
	pass;	
func on_hit(projectile:Projectile):
	
	if on_hit_node==null:return
	if projectile==null:return
	var dup
	if on_hit_cache.is_empty():
		dup=$on_hit.duplicate()
		dup.finished.connect(func():
			on_hit_cache.push_back(dup)
			remove_child(dup))
	else:
		dup=on_hit_cache.pop_back()
		
	add_child(dup)
	dup.global_position=projectile.global_position
	on_shoot_node.process_material.direction=Vector3(projectile.direction.x*-1,projectile.direction.y*-1,0)	
	dup.restart()
	dup.emitting=true;
			
	pass;
