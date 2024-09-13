extends TurretCore
class_name GreenTurretCore
@export var projectile_destroy_timeout:float=2
@export var num_active_projectiles=3
var delay_between_projectiles=1
var in_range=false;
var projectiles_active=false;
signal destroy_projectiles
func attack(delta):
	if target==null:
		in_range=false;
		get_tree().create_timer(projectile_destroy_timeout).timeout.connect(destroy_projectiles_conditional)
	else:
		in_range=true
		if not projectiles_active:
			var delay=0
			var p= shoot(target)
			for i in range(num_active_projectiles-1):
				delay+=delay_between_projectiles
				get_tree().create_timer(delay).timeout.connect(shoot.bind(target))
				
			
			#shoot(target)
			projectiles_active=true	
	pass
func on_destroy():
	destroy_projectiles.emit()
	super()
	pass;	
#func shoot(target):
	#var shot = get_projectile()
	#shot.global_position = global_position
	#shot.shoot(target);
	#
	#return shot
func destroy_projectiles_conditional():
	if in_range:return
	destroy_projectiles.emit()
	projectiles_active=false;
	pass;	
func get_projectile():
	var t=super()
	destroy_projectiles.connect(t.destroy)
	return t
	pass;	
func getReferences(cells):
	return collisionReference.getNeighbours(global_position,cells)
	pass;		
func on_projectile_removed(projectile:Projectile):
	#get_tree().create_timer(projectile_destroy_timeout).timeout.connect(shoot.bind(null))
	#super(projectile)
	pass;
func after_built():
	super()
	#if not placed:return
	#for i in range(num_active_projectiles):
		#get_tree().create_timer(i*1.5).timeout.connect(shoot.bind(null))

	pass;	

