extends Node
class_name util

static func p(msg:String,fromperson:String="Someone",type:String="Debug"):
	print("Type: "+type +" From: "+ fromperson+ " MSG: "+msg);
	pass;

class Distance:
	var from: int
	var to: int
	func _init(from: int, to: int):
		self.from = from
		self.to = to

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
