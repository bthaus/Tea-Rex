extends EntityDTO
class_name PortalDTO
var entry=ENTRY_TYPE.BIDIRECTIONAL
var group_id=0
var map_layer: GameboardConstants.MapLayer
var collides: bool

enum ENTRY_TYPE{BIDIRECTIONAL,IN,OUT}

func _init(tile_id: int=0, map_layer: GameboardConstants.MapLayer = GameboardConstants.MapLayer.BLOCK_LAYER, map_x: int = -1, map_y: int = -1, collides=false, group_id=0, entry=ENTRY_TYPE.BIDIRECTIONAL):
	self.entry=entry
	self.group_id=group_id
	self.collides = collides
	super(tile_id, map_x, map_y)

func get_object():
	return Portal.new(tile_id,map_layer, Vector2(map_x,map_y), group_id, entry)
	

