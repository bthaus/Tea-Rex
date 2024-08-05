extends GameObject2D
class_name EntityFactory

static var instance=load("res://factories/entity_factory.tscn").instantiate()
static func create(dto:EntityDTO):
	var node
	for n:BaseEntity in get_all():
		if node.tile_id==dto.tile_id:
			node=n.duplicate()
			break;
			
	node.map_position=Vector2(dto.map_x,dto.map_y)
	
	return node
	pass;
	
static func get_all():
	return instance.get_children()
	pass;
