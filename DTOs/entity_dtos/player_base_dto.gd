extends EntityDTO
class_name PlayerBaseDTO
var color: GameboardConstants.TileColor

func _init(tile_id: int = -1, map_layer: int = -1, color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE, map_x:  int = -1, map_y: int = -1):
	super(tile_id, map_layer, map_x, map_y)
	self.color = color
	
func get_object():
	return PlayerBase.new(tile_id, map_layer, Vector2(map_x, map_y),color)
