extends EntityDTO
class_name PlayerBaseDTO

var color: GameboardConstants.TileColor
var map_layer: GameboardConstants.MapLayer

func _init(tile_id: int = -1, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.BLOCK_LAYER, color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE, map_x:  int = -1, map_y: int = -1):
	super(tile_id, map_x, map_y)
	self.color = color
	
func get_object():
	return PlayerBase.new(tile_id, map_layer, Vector2(map_x, map_y), color)
