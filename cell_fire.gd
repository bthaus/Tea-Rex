extends GPUParticles2D
class_name CellFire
@export var size:int=1
func _ready():
	set_size(size)
	pass;



func set_size(val):
	process_material.emission_box_extents=Vector3(32*val,32*val,1)
	amount*=val*val
	pass;
