extends TurretCore
class_name RedTurretCore
@export var projectile_destroy_timeout:float=2
@export var num_active_projectiles=3

func do(delta):
	return
func getReferences(cells):
	return collisionReference.getNeighbours(global_position,cells)
	pass;		
func on_projectile_removed(projectile:Projectile):
	get_tree().create_timer(projectile_destroy_timeout).timeout.connect(shoot.bind(null))
	super(projectile)
	pass;
func after_built():
	super()
	if not placed:return
	for i in range(num_active_projectiles):
		get_tree().create_timer(i).timeout.connect(shoot.bind(null))

	pass;	

