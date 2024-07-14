extends GameObject2D
class_name Stats;
static var rng=RandomNumberGenerator.new()

enum TurretColor {WHITE=1, GREEN=2, RED=3, YELLOW=4, BLUE=5, MAGENTA=6};
enum TurretExtension {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWMORTAR=4, GREENPOISON=5,BLUEFREEZER=6};
enum GamePhase {BATTLE=1,BUILD=2,BOTH=3};
enum Monstertype {REGULAR=0}

#legacy code. keep in bc its simple af stuff, and they're basically just auxiliary stuff
static func getStringFromEnum(type:TurretColor):
	return Stats.TurretColor.keys()[(type)-1];
static func getStringFromEnumLowercase(type:TurretColor):
	return Stats.TurretColor.keys()[(type)-1].to_lower();
static func getStringFromEnumExtension(type:TurretExtension):
	match type:
		1: return ""
		2: return "LASER"
		3: return "LASER"
		4: return "MORTAR"
		5: return "POISON"
		6: return "FREEZER"
	return "";

static var colorit=1;
static var counter=0;

static func getRandomColor(gamestate):
	return GameState.gameState.unlockedColors.pick_random()	
		
func getRandomBlock(lvl,gamestate):
	var rng=RandomNumberGenerator.new()
	var color=getRandomColor(gamestate)
	var extension=TurretExtension.DEFAULT
	var block=getEvaluatedShape(0)
	return BlockUtils.get_block_from_shape(block,color,lvl,extension)

static var numberOfPiecesDrawn:float=1;
static var numberOfCardsDrawn:float=1;
static var TargetPieceAverage:float=3.5;
static var tolerance:float=0.5

static var bestCurrentShape=null;
static var bestCurrentAverage=1;

static func getRandomCard(gamestate):
	return BlockCard.create(gamestate)
	
func getEvaluatedShape(counter):
	var shape=Block.BlockShape.values()[rng.randi_range(0,Block.BlockShape.size()-1)]
	var block=BlockUtils.get_block_from_shape(shape,0,0);
	var currentPieces=+numberOfPiecesDrawn+block.pieces.size()
	var currentAverage=currentPieces/numberOfCardsDrawn 
	
	if bestCurrentAverage != null and currentAverage>bestCurrentAverage:
		bestCurrentAverage=currentAverage
		bestCurrentShape=shape
	var difference=currentAverage-TargetPieceAverage
	
	if counter>20:
		numberOfPiecesDrawn=numberOfPiecesDrawn+block.pieces.size();
		return bestCurrentShape;
	if abs(difference)>tolerance:
		return getEvaluatedShape(counter+1)
		
	numberOfPiecesDrawn=numberOfPiecesDrawn+block.pieces.size();	
	return shape;	
