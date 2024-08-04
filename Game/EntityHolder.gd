extends GameObject2D
class_name EntityHolder

func do(delta):
	for entity:BaseEntity in get_children():
		entity.do(delta)
		pass;
	pass;

