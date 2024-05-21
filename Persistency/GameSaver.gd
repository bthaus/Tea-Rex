extends  Node

class_name GameSaver
static var extensionimplemented=false;
@export var state:GameState;

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
static var basegamename="basegamesavename";
static func createBaseGame(gameState:GameState):
	var oldname=gameState.account
	gameState.account=basegamename
	saveGame(gameState)
	gameState.account=oldname
	pass;
static func restoreBaseGame(gameState:GameState):
	var oldname=gameState.account
	gameState.account=basegamename
	restoreGame(gameState)
	gameState.account=oldname
	saveGame(gameState)
	pass;
static func restoreGame(gameState:GameState):	
	
	var data=JSON.parse_string((loadfile("state",gameState.account)))
	if data==null:
		restoreBaseGame(gameState)
		return
	var ignoredData=["GameState.gd","gameBoard","hand","menu","cam","lightThresholds","target","spawners","unlock"]
	for d in data:
		var da=JSON.parse_string(d) as Dictionary
		var dakey=da.keys()[0]
		if ignoredData.find(dakey)==-1:
			gameState.set(dakey,da.get(dakey))
	gameState.cleanUpAllFreedNodes		
	gameState.collisionReference.queue_free()
	gameState.collisionReference=CollisionReference.new()
	gameState.collisionReference.initialise(gameState)		
	gameState.collisionReference.addRows()		
	deserialiseSpawners(gameState,loadfile("spawners",gameState.account))
	loadGameMap(gameState);
	loadHand(gameState)
	gameState.phase=Stats.GamePhase.BUILD
	pass
static func remove(name):
	loadfile("state",name)
	print(DirAccess.remove_absolute("user://save_gamestate_"+name+".dat"))
	
	DirAccess.remove_absolute("user://save_gamemap_"+name+".dat")
	DirAccess.remove_absolute("user://save_gamehand_"+name+".dat")
	
	pass;	
static func saveGame(gameState:GameState):
	
	
	if gameState.menu!= null:
		gameState.menu.showSaving()
	print("save called")
	var props=gameState.get_script().get_script_property_list()
	var values=[]
	
	
	for p in props:
		var d={p["name"]:gameState.get(p["name"])}
		values.append(JSON.stringify(d))
	save(JSON.stringify(values),"state",gameState.account);		
	storeGameMap(gameState)
	storeHand(gameState)
	save(serialseSpawners(gameState),"spawners",gameState.account)
	pass;
static func storeHand(gameState:GameState):
	if gameState.hand==null:
		return
	var json=serialiseHand(gameState.hand.get_children());
	save(json,"hand",gameState.account)
	pass;
static func storeGameMap(gameState:GameState):
	if gameState.gameBoard == null: return

	var map=gameState.gameBoard.get_child(0) as TileMap
	
	var cells=map.get_used_cells(0);
	var mapAsArray=[]
	for cell in cells:
		#var turret=gameState.gameBoard.turret_holder.get_turret_at(cell)
		var data=map.get_cell_tile_data(GameBoard.BLOCK_LAYER,cell)
		if data==null:util.p("cell tile data empty for some reason","bodo","persistency");
		var color=data.get_custom_data("color");
		var level=data.get_custom_data("level");
		var extension=1
		var extensionData=map.get_cell_tile_data(GameBoard.EXTENSION_LAYER,cell)
		if extensionData!=null:
			extension=extensionData.get_custom_data("extension");
		if color=="WALL":
			level=map.get_cell_source_id(GameBoard.BLOCK_LAYER,cell)	
		var info=Info.new(color,level,extension,cell)
		
		mapAsArray.append(info.serialise())
	save(JSON.stringify(mapAsArray),"map",gameState.account)
	
	pass;	
static func loadHand(gameState:GameState):
	for c in gameState.hand.get_children():
		c.queue_free();
	var handstring=loadfile("hand",gameState.account)
	var hand=deserialiseHand(handstring,gameState)
	pass;
static func loadGameMap(gameState:GameState):
	gameState.gameBoard.queue_free()
	var newBoard=load("res://GameBoard/game_board.tscn").instantiate() 
	gameState.gameBoard=newBoard
	gameState.board=newBoard.get_node("Board")
	newBoard.gameState=gameState
	gameState.add_child(newBoard)
	var mapstring=loadfile("map",gameState.account)
	var mapAsArray=JSON.parse_string(mapstring);
	var pieces=[]
	var walls=[]
	for d in mapAsArray:
		var p=Info.deserialise(d);
		if p.color==-3:
			walls.append(Vector3(p.position.x,p.position.y,p.level))
		else:
			pieces.append(p);
		
	var block=Block.new(pieces);
	
	gameState.gameBoard._place_block(block,Vector2(0,0));
	#gameState.gameBoard.init_field()
	gameState.gameBoard.draw_field_from_walls(walls)
	gameState.gameBoard.get_node("NavigationRegion2D").bake_navigation_polygon()
	#gameState.gameBoard._spawn_all_turrets()
	pass;

static func save(content:String, destination:String, save:String):
	var file = FileAccess.open("user://save_game"+destination+"_"+save+".dat", FileAccess.WRITE)
	file.store_string(content)
	
	pass;

static func loadfile(destination:String, save:String):
	var file = FileAccess.open("user://save_game"+destination+"_"+save+".dat", FileAccess.READ)
	var err=FileAccess.get_open_error()
	if err>0:
		print("error loading file with "+save)
		
		return "";
	var content = file.get_as_text()
	return content
class Data:
	var key:String;
	var value:Variant;
	
	
	func _init(s:String,v:Variant):
		key=s;
		value=v;
	func serialise()->String:
		return JSON.stringify(self)
		
	static func deserialise(string:String)->Data:
		var d=JSON.parse_string(string);
		return d
			
	pass	
static func serialseSpawners(gameState:GameState):
	var spawners=[]
	for s:Spawner in gameState.spawners:
		spawners.append(s.serialise())
	return JSON.stringify(spawners)
	pass
static func deserialiseSpawners(gameState:GameState,json):
	var jarr=JSON.parse_string(json)
	#Clear all spawners
	gameState.spawners.clear()
	for child in gameState.get_children():
		if child is Spawner:
			child.queue_free()
	for j in jarr:
		Spawner.deserialise(j,gameState)
	pass;
static func serialiseHand(hand:Array):
	
	var cards=[]
	for ci in hand:
		var c=ci.card
		
		if c is SpecialCard:
			cards.append(JSON.stringify({"special":c.cardName,"round":c.roundReceived}))	
		if c is BlockCard:
			var b=c.block as Block
			cards.append(JSON.stringify({"block":b.shape,"color":b.color,"extension":b.extension}))
	return JSON.stringify(cards)
static func deserialiseHand(json,gamestate:GameState):
	
	var hand=JSON.parse_string(json);
	for j in hand:
		var card=JSON.parse_string(j) as Dictionary
		var keys=card.keys()
		if keys.size()==2:
			var c=SpecialCard.create(gamestate,card["special"])
			c.roundReceived=card["round"]
			gamestate.hand.add_child(Card.create(gamestate,c))
		else:
			var block=Stats.getBlockFromShape(card.get("block"),card.get("color"),1,card.get("extension"))
			gamestate.hand.add_child(Card.create(gamestate,BlockCard.create(gamestate,block)))
	
	pass;
class Info:
	var data=[]
	func _init(color,level,extension,cell):
		
		data.append(color);
		data.append(level);
		data.append(extension);
		data.append(cell.x);
		data.append(cell.y);
		
		pass;
	func serialise()->String:
		return JSON.stringify(data)
		
		
	
	static func deserialise(str:String)->Block.Piece:
		var data=JSON.parse_string(str)
		if data[2]!=null and (data[2] is String) and Stats.getEnumFromString(data[2])>1:
			return Block.Piece.new(Vector2(data[3],data[4]),Stats.getColorFromString(data[0]),data[1],Stats.getEnumFromString(data[2]));
		else:
			return Block.Piece.new(Vector2(data[3],data[4]),Stats.getColorFromString(data[0]),data[1]);
	
		
		return null;
		
	
