extends EntityDTO
class_name PlayerBaseDTO

var color: GameboardConstants.TileColor
var map_layer: GameboardConstants.MapLayer

func _init(tile_id: int = -1, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.BLOCK_LAYER, color: GameboardConstants.TileColor = GameboardConstants.TileColor.NONE, map_x:  int = -1, map_y: int = -1):
	super(tile_id, map_x, map_y)
	self.color = color
	self.map_layer = map_layer
	
func get_object():
	return PlayerBase.new(tile_id, map_layer, Vector2(map_x, map_y), color)

func get_compact_string():
	var s=super()
	s=s.replace("-","_")
	s+=str(color)+"_"+str(map_layer)+"-"
	return s
static func parse_compact_string(s):
	var p=s.split("_")
	return PlayerBaseDTO.new(int(p[0]),
	int(p[4]),
	int(p[3]),
	int(p[1]),
	int(p[2]))
	pass;	
	
