extends EntityDTO
class_name PlayerBaseDTO
var color
func _init(tile_id: int = -1, map_layer: int = -1, map_x:  int = -1, map_y: int = -1):
	super(tile_id, map_layer, map_x, map_y)
	
func get_object():
	return PlayerBase.new(tile_id, map_layer, Vector2(map_x, map_y),color)
