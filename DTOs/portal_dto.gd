extends TileDTO
class_name PortalDTO
var entry=ENTRY_TYPE.BIDIRECTIONAL
var group_id=0

enum ENTRY_TYPE{BIDIRECTIONAL,IN,OUT}



func _init(tile_id: int=0, layer: int=0, map_position: Vector2=Vector2(0,0),collides=false,group_id=0,entry=ENTRY_TYPE.BIDIRECTIONAL):
	self.entry=entry
	self.group_id=group_id
	super(tile_id, layer, map_position.x, map_position.y,collides)

func get_object():
	return Portal.new(tile_id,map_layer, Vector2(map_x,map_y),group_id,entry)
	

