extends BaseEntity
class_name Portal
var entry=ENTRY_TYPE.BIDIRECTIONAL
var group_id=0

enum ENTRY_TYPE{BIDIRECTIONAL,IN,OUT}

func _init(tile_id: int, map_layer: GameboardConstants.MapLayer, map_position: Vector2,group_id=0,entry=ENTRY_TYPE.BIDIRECTIONAL):
	self.entry=entry
	self.group_id=group_id
	super(tile_id, map_layer, map_position)
	self.tile_id = tile_id
	self.map_layer = map_layer

func trigger_minion(minion:Monster):
	if entry==ENTRY_TYPE.IN or entry==ENTRY_TYPE.BIDIRECTIONAL:
		minion.trigger_teleport()
	pass;
func place_on_board(board: TileMap):
	GameState.gameState.portals.append(self)
	super(board)
	pass;
