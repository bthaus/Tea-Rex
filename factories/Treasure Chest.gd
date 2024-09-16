extends BaseEntity
class_name TreasureChest
var id:String=""
var unlockable:Unlockable

func place_on_board(b:TileMap):
	var map_dto=GameState.gameState.map_dto;
	id=str(map_position.x)+"_"+str(map_position.y)+"_"+map_dto.map_name+"_"+Global.get_account().account_name
	var account=Global.get_account();
	if account.unlocked_treasures.has(id):
		queue_free()
		return;
	var item=map_dto.treasures[id]	
	super(b)
	pass;
func trigger_minion(m:Monster):
	
	super(m)
	pass;
