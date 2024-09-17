extends BaseEntity
class_name TreasureChest
var id:String=""
var item
var collected
@export var collect_on_win:bool=true

func place_on_board(b:TileMap):
	var map_dto=GameState.gameState.map_dto;
	id=str(map_position.x)+"_"+str(map_position.y)+"_"+map_dto.map_name
	if GameState.gameState is EditorGameState:
		GameState.gameState.map_dto.treasure_ids.append(id)
		print("id added: "+id)
		print("current ids: ")
		for i in GameState.gameState.map_dto.treasure_ids:
			print(i)
	else:
		register_in_gamestate()
	super(b)
	pass;
func register_in_gamestate():
	var account=Global.get_account();
	if util.valid(account) and account.unlocked_treasures.has(id):
		queue_free()
		return;
	for t in GameState.gameState.map_dto.treasures:
		if t is TreasureDTO and t.id==id:
			item=t.item;
	if item == null:
		print("treasure chest without content warning, id: "+id)			
	pass;	

func trigger_minion(m:Monster):
	if collected:return
	remove_from_board(GameState.board)
	if collect_on_win:
		GameState.gameState.game_won.connect(collect)	
	else:
		collect()	
	collected=true;
	super(m)
	pass;
func remove_from_board(b:TileMap):
	if GameState.gameState is EditorGameState:
		GameState.gameState.map_dto.treasure_ids.erase(id)
		print("id removed: "+id)
	super(b)	
	pass;	
func collect():
	GameState.gameState.show_unlockable(Unlockable.create(item))
	if item is TurretBaseMod:
		Global.get_account().add_unlocked_mod(item)
	if item is String:
		Global.get_account().add_unlocked_map(item)	
	pass;	
