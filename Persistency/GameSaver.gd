extends  Node

class_name GameSaver
static var extensionimplemented=false;


# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass

	
static func restoreGame(gameState:GameState):	
	loadGameMap(gameState);

	gameState.unlockedColors=JSON.parse_string(loadfile("unlockedColors",gameState.account))
	gameState.unlockedExtensions=JSON.parse_string(loadfile("unlockedExtensions",gameState.account))
	gameState.unlockedSpecialCards=JSON.parse_string(loadfile("unlockedSpecialCards",gameState.account))
	gameState.phase=JSON.parse_string(loadfile("phase",gameState.account))
	gameState.HP=JSON.parse_string(loadfile("hp",gameState.account))
	gameState.handCards=JSON.parse_string(loadfile("handCards",gameState.account))
	gameState.wave=JSON.parse_string(loadfile("wave",gameState.account))

	pass
	
static func saveGame(gameState:GameState):

		
	save(JSON.stringify(gameState.unlockedColors),"unlockedColors",gameState.account);
	save(JSON.stringify(gameState.unlockedExtensions),"unlockedExtensions",gameState.account);
	save(JSON.stringify(gameState.unlockedSpecialCards),"unlockedSpecialCards",gameState.account);
	save(JSON.stringify(gameState.phase),"phase",gameState.account);
	save(JSON.stringify(gameState.HP),"hp",gameState.account);
	save(JSON.stringify(gameState.handCards),"handCards",gameState.account);
	save(JSON.stringify(gameState.wave),"wave",gameState.account)
	var map=gameState.gameBoard.get_child(0) as TileMap
	
	var cells=map.get_used_cells(0);
	var mapAsArray=[]
	for cell in cells:
		var data=map.get_cell_tile_data(0,cell)
		var color=data.get_custom_data("color");
		var level=data.get_custom_data("level");
		var extension;
		if extensionimplemented:
			extension=data.get_custom_data("extension");
		else:
			extension=Stats.TurretExtension.DEFAULT;
		var info=Info.new(color,level,extension,cell)
		mapAsArray.append(info.serialise())
	save(JSON.stringify(mapAsArray),"map",gameState.account)
	
	pass;	
static func loadGameMap(gameState):
	var mapstring=loadfile("map",gameState.account)
	var mapAsArray=JSON.parse_string(mapstring);
	var pieces=[]
	for d in mapAsArray:
		pieces.append(Info.deserialise(d));
		
	var block=Block.new(pieces);

	gameState.gameBoard.block_handler.draw_block(block,Vector2(0,0),0);
	pass;

static func save(content:String, destination:String, save:String):
	var file = FileAccess.open("user://save_game"+destination+"_"+save+".dat", FileAccess.WRITE)
	file.store_string(content)
	
	pass;

static func loadfile(destination:String, save:String):
	var file = FileAccess.open("user://save_game"+destination+"_"+save+".dat", FileAccess.READ)
	print(FileAccess.get_open_error())
	var content = file.get_as_text()
	return content
	
class Info:
	var data=[]
	func _init(c,l,e,cell):
		data.append(c);
		data.append(l);
		data.append(Stats.getStringFromEnumExtensionLowercase(e));
		data.append(cell.x);
		data.append(cell.y);
		pass;
	func serialise()->String:
		return JSON.stringify(data)
		
		
	
	static func deserialise(str:String)->Block.Piece:
		var data=JSON.parse_string(str)
		return Block.Piece.new(Vector2(data[3],data[4]),Stats.getColorFromLowercaseString(data[0]),data[1]);
	
		return null;
		
	
