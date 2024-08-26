extends BaseEntity
class_name Build

var allowed_color: GameboardConstants.TileColor

func _init(tile_id: int, layer: int, map_position: Vector2, allowed_color: GameboardConstants.TileColor):
	super(tile_id, layer, map_position)
	self.allowed_color = allowed_color
	self.tile_id = tile_id
	self.map_layer = map_layer
