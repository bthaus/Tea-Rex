extends EntityDTO
class_name SpawnerDTO
var spawner_id: int
var map_layer: GameboardConstants.MapLayer
var color: GameboardConstants.TileColor

func _init(tile_id: int = -1, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.BLOCK_LAYER, spawner_id: int = -1, color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE, map_x: int = -1, map_y: int = -1):
	self.spawner_id = spawner_id
	self.map_layer = map_layer
	self.color = color
	super(tile_id, map_x, map_y)
	
func get_object():
	return Spawner.create(tile_id, map_layer, Vector2(map_x, map_y), spawner_id, color)

func get_compact_string():
	var s=super()
	s=s.replace("-","_")
	s+=str(spawner_id)+"_"+str(map_layer)+"_"+str(color)+"-"
	return s
static func parse_compact_string(s):
	var p=s.split("_")
	return SpawnerDTO.new(
		int(p[0]),
		int(p[4]),
		int(p[3]),
		int(p[5]),
		int(p[1]),
		int(p[2])
	)
	pass;	
