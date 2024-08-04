extends GameObject2D
class_name EntityFactory

static var instance=load("res://factories/entity_factory.tscn").instantiate()
static func create(dto:EntityDTO):
	var node= instance.get_node("ForestEntity").duplicate()
	node.map_layer=dto.map_layer
	node.tile_id=dto.tile_id
	node.map_position=Vector2(dto.map_x,dto.map_y)
	
	return node
	pass;
