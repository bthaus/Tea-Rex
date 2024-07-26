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

class TurretHolder:
	var _turrets = []
	func insert_turret(turret: Turret):
		var row = _binary_search_row(turret.position.y)
		if row >= 0:
			var col = _binary_search_col(turret.position.x, row)
			if col >= 0:
				_turrets[row][col] = turret
			else:
				_turrets[row].insert(-col-1, turret)
		else:
			_turrets.insert(-row-1, [turret])
	
	func get_turret_at(position: Vector2) -> Turret:
		var row = _binary_search_row(position.y)
		if row >= 0:
			var col = _binary_search_col(position.x, row)
			if col >= 0:
				return _turrets[row][col]
		return null
	
	func pop_turret_at(position: Vector2) -> Turret:
		var row = _binary_search_row(position.y)
		if row >= 0:
			var col = _binary_search_col(position.x, row)
			if col >= 0:
				var turret = _turrets[row].pop_at(col)
				if _turrets[row].size() == 0:
					_turrets.remove_at(row)
				return turret
		return null

	func _binary_search_row(row: int) -> int:
		var left = 0
		var right = _turrets.size()-1
		while (left <= right):
			var mid = left + (right - left) / 2
			#Check if x is present at mid
			if (_turrets[mid][0].position.y == row):
				return mid;
			#If x greater, ignore left half
			if (_turrets[mid][0].position.y < row):
				left = mid + 1;
			#If x is smaller, ignore right half
			else:
				right = mid - 1;
		#Element is not present, return insertion point. Add 1 to avoid 0 being indistinguishable between found/not found 
		return -(left+1);
		
	func _binary_search_col(col, row: int) -> int:
		var left = 0
		var right = _turrets[row].size()-1
		while (left <= right):
			var mid = left + (right - left) / 2
			#Check if x is present at mid
			if (_turrets[row][mid].position.x == col):
				return mid;
			#If x greater, ignore left half
			if (_turrets[row][mid].position.x < col):
				left = mid + 1;
			#If x is smaller, ignore right half
			else:
				right = mid - 1;
		#Element is not present, return insertion point. Add 1 to avoid 0 being indistinguishable between found/not found
		return -(left+1);

static func getStringFromEnum(type:Turret.Hue):
	return Turret.Hue.keys()[(type)-1];
static func getStringFromEnumLowercase(type:Turret.Hue):
	return Turret.Hue.keys()[(type)-1].to_lower();
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
static func copy_object_shallow(obj):
	var props=obj.get_script_property_list() as Array
	return load(props.pop_front()["hint_string"]).new()
	pass;
