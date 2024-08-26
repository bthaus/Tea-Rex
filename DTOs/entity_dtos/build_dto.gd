extends EntityDTO
class_name BuildDTO

var allowed_color: GameboardConstants.TileColor
var map_layer = GameboardConstants.MapLayer

func _init(tile_id: int = -1, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.BUILD_LAYER, allowed_color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE, map_x:  int = -1, map_y: int = -1):
	super(tile_id, map_x, map_y)
	self.allowed_color = allowed_color
	self.map_layer = map_layer

func get_object():
	return Build.new(tile_id, map_layer, Vector2(map_x, map_y), allowed_color)
