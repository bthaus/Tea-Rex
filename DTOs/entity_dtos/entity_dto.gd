extends BaseDTO
class_name EntityDTO

var tile_id: int
var map_x: int
var map_y: int

func _init(tile_id: int=-1, map_x: int=-1, map_y: int=-1):
	self.tile_id = tile_id
	self.map_x = map_x
	self.map_y = map_y
	
func get_object():
	return EntityFactory.create(self)

func get_compact_string():
	return str(tile_id)+"_"+str(map_x)+"_"+str(map_y)+"-"

static func parse_compact_string(s):
	var t=s.split("_")
	var id=int(t[0])
	if id==GameboardConstants.PORTAL_TILE_ID:
		return PortalDTO.parse_compact_string(s)
	if id==GameboardConstants.PLAYER_BASE_GREEN_TILE_ID:
		return PlayerBaseDTO.parse_compact_string(s)	
	if id==GameboardConstants.SPAWNER_GREEN_TILE_ID:
		return SpawnerDTO.parse_compact_string(s)
	return EntityDTO.new(int(t[0]),int(t[1]),int(t[2]))		
	pass;
