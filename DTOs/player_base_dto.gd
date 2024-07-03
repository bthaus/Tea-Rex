extends EntityDTO
class_name PlayerBaseDTO

func _init(tile_id: int = -1, x: int = -1, y: int = -1):
	super(tile_id, x, y)
	
func get_object():
	return PlayerBase.new(tile_id, x, y)
