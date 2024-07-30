extends Node
class_name util
static func rotate_vector(vector: Vector2,val) -> Vector2:
	# 45 degrees in radians
	var angle = deg_to_rad(val)

	# Calculate the rotation matrix components
	var cos_angle = cos(angle)
	var sin_angle = sin(angle)

	# Apply the rotation matrix
	var x_new = vector.x * cos_angle - vector.y * sin_angle
	var y_new = vector.x * sin_angle + vector.y * cos_angle

	# Return the rotated vector
	return Vector2(x_new, y_new)	

static func p(msg:String,fromperson:String="Someone",type:String="Debug"):
	print("Type: "+type +" From: "+ fromperson+ " MSG: "+msg);
	pass;

static func is_str_valid_positive_int(str: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(str)
	if result == null or result.get_string() != str:
		return false
	return true

static func getStringFromEnum(type:Turret.Hue):
	return Turret.Hue.keys()[(type)];
static func getStringFromEnumLowercase(type:Turret.Hue):
	return Turret.Hue.keys()[(type)].to_lower();
static func getStringFromEnumExtension(type:Turret.Extension):
	match type:
		1: return ""
		2: return "LASER"
		3: return "LASER"
		4: return "MORTAR"
		5: return "POISON"
		6: return "FREEZER"
	return "";



static func getRandomBlock(lvl,gamestate):
	var rng=RandomNumberGenerator.new()
	var color=GameState.gameState.unlockedColors.pick_random()	
	var extension=Turret.Extension.DEFAULT
	var block=getEvaluatedShape(0)
	return BlockUtils.get_block_from_shape(block,color,lvl,extension)



static func getEvaluatedShape(counter):
	#return Block.BlockShape.TINY
	return Block.BlockShape.values().pick_random()
	var shape=Block.BlockShape.values()[RandomNumberGenerator.new().randi_range(0,Block.BlockShape.size()-1)]
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

static var numberOfPiecesDrawn:float=1;
static var numberOfCardsDrawn:float=1;
static var TargetPieceAverage:float=3.5;
static var tolerance:float=0.5

static var bestCurrentShape=null;
static var bestCurrentAverage=1;
static func erase(obj):
	if obj!=null and is_instance_valid(obj):
		obj.queue_free()
	pass;
static func valid(obj)->bool:
	return obj!=null and is_instance_valid(obj)	
static func copy_object_shallow(obj):
	var props=obj.get_script_property_list() as Array
	return load(props.pop_front()["hint_string"]).new()
	pass;
