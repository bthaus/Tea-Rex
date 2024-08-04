extends GPUParticles2D
class_name CellFire

func _ready():
	set_size(5)
	pass;

func set_size(val):
	process_material.emission_box_extents*=val
	amount*=val*val
	pass;
