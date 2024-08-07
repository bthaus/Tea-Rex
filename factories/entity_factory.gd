extends GameObject2D
class_name EntityFactory

func _ready():
	for n:BaseEntity in get_all():
		n.print_data()
	pass;

static var instance=preload("res://factories/entity_factory.tscn").instantiate()
static func create(dto:EntityDTO):
	var node
	
	for n in get_all():
		if n.tile_id==dto.tile_id:
			node=n.duplicate()
			break;
	node=instance.get_node("Spielverderber").duplicate()		
	node.map_position=Vector2(dto.map_x,dto.map_y)
	node.visible=true
	return node
	pass;
	
static func get_all():
	var c =instance.get_children()
	return c
	pass;
	
