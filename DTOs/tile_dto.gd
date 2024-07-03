extends EntityDTO
class_name TileDTO

func _init(tile_id: int = -1, layer: int = -1, x: int = -1, y: int = -1):
	super(tile_id, layer, x, y)

func get_object():
	return Tile.new(tile_id, map_layer, Vector2(map_x, map_y))
