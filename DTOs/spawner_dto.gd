extends EntityDTO
class_name SpawnerDTO
var spawner_id: int
var color: GameboardConstants.TileColor

func _init(tile_id: int = -1, map_layer: int = -1, map_x: int = -1, map_y: int = -1, spawner_id: int = -1, color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE):
	self.spawner_id=spawner_id
	self.color = color
	super(tile_id, map_layer, map_x, map_y)
	
func get_object():
	return Spawner.create(tile_id, map_layer, Vector2(map_x, map_y), spawner_id, color)
