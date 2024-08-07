extends EntityDTO
class_name TileDTO

var map_layer: GameboardConstants.MapLayer
var collides: bool

func _init(tile_id: int = -1, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.GROUND_LAYER, x: int = -1, y: int = -1,collides:bool=false):
	self.collides = collides
	super(tile_id, x, y)

func get_object():
	return Tile.new(tile_id, map_layer, Vector2(map_x, map_y))
