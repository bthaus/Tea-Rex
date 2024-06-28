extends Node
class_name CollisionReference

var gameState: GameState
var map = [];
var rowCounter = []
var basepos=Vector2(0,0)
static var instance;
static func normaliseX(x):
	return x + 9;
static func normaliseY(y):
	return y - 1;
	
static func normaliseVector(pos):
	return Vector2(normaliseX(pos.x), normaliseY(pos.y))
	pass ;
func removeNnullReferences(n):
	var removals=[]
	for y in range(map.size()):
		for x in range(map[y].size()):
			for z in range(map[y][x].ms.size()):
				if map[y][x].ms[z]==null:
					removals=Vector3(x,y,z);
					n=n-1
					if n==0:
						for r in removals:
							map[r.y][r.x].ms.remove_at(r.z)
	
	pass;
		
func removeMonster(mo):
	var pos = normaliseVector(instance.gameState.board.local_to_map(mo.global_position));
	var beforesize=map[pos.y][pos.x].ms.size()
	map[pos.y][pos.x].ms.erase(mo)
	var aftersize=map[pos.y][pos.x].ms.size()
	if beforesize==aftersize:
		print("minion not found on position.searching for it..")
		#removeNnullReferences(1)
		
		
	pass ;
func setMinion(oldx, oldy, x, y, m: Monster):
	oldx = normaliseX(oldx)
	x = normaliseX(x)
	y = normaliseY(y)
	oldy = normaliseY(oldy)
	if y>map.size():
		addRows()
	map[oldy][oldx].ms.erase(m)
	if x==basepos.x and y==basepos.y:
		gameState.hit_base(m)
		return;
	map[y][x].ms.push_back(m)
	if oldy != y:
		rowCounter[oldy] = rowCounter[oldy] - 1
		rowCounter[y] = rowCounter[y] + 1
	
	pass ;
	
func getMapFromReference(pos):
	return Vector2(pos.x - 9, pos.y + 1)
func getGlobalFromReference(pos):
	return GameState.gameState.board.map_to_local(getMapFromReference(pos))
	pass ;
func get_monster(pos):
	
	pos.x = normaliseX(pos.x)
	pos.y = normaliseY(pos.y)
	
	#if rowCounter[pos.y-1]>0:
	if map[pos.y][pos.x].ms.size() > 0:
		
		var mo = map[pos.y][pos.x].ms.back()
		return mo
		#return map[pos.y][pos.x].ms[0]
	#map[pos.y][pos.x].ms	
	return null;
	pass ;
func getMapPositionNormalised(pos):
	pos = gameState.board.local_to_map(pos)
	return normaliseVector(pos)
	pass ;
func initialise(g):
	gameState = g
	instance = self;
	Turret.collisionReference = self;
	gameState.get_node("MinionHolder").reference = self;
	gameState.get_node("BulletHolder").reference = self;
	gameState.collisionReference = self;
	
	for i in range(gameState.board_height):
		addRow(map)
	pass ;
func addRows():
	for i in range(gameState.board_height + 20 - map.size()):
		addRow(map)
	pass ;
func addRow(y: Array):
	var row = []
	addholders(row)
	y.append(row)
	var row2 = []
	addholders(row2)
	y.append(row2)
	rowCounter.append(0)
	rowCounter.append(0)
	pass ;
	
func registerBase(base):
	var pos=getMapPositionNormalised(base.global_position)
	basepos=pos;
	pass;	
func getMinionsAroundPosition(pos):
	if isOutOfBounds(pos.x,pos.y):return [];
	var cells = getNeighbours(pos);
	pos = getMapPositionNormalised(pos)
	cells.append(map[pos.y][pos.x].ms)
	var minions = []
	for ms in cells:
		minions.append_array(ms)
	return minions
	pass ;
	
func clearUp():
	for y in map:
		for x in y:
			x.ms.clear()
	pass ;
func getNeighbours(pos, reference=null):
	var p = getMapPositionNormalised(pos)
	var coveredCells = []
	if isOutOfBounds(p.x,p.y):
		return coveredCells;
	coveredCells.append(map[p.y + 1][p.x + 1].ms)
	coveredCells.append(map[p.y - 1][p.x + 1].ms)
	coveredCells.append(map[p.y + 1][p.x - 1].ms)
	coveredCells.append(map[p.y - 1][p.x - 1].ms)
	coveredCells.append(map[p.y + 1][p.x].ms)
	coveredCells.append(map[p.y - 1][p.x].ms)
	coveredCells.append(map[p.y][p.x + 1].ms)
	coveredCells.append(map[p.y][p.x - 1].ms)
	
	if reference != null:
		reference.append(Vector2(p.x + 1, p.y + 1))
		reference.append(Vector2(p.x - 1, p.y + 1))
		reference.append(Vector2(p.x + 1, p.y - 1))
		reference.append(Vector2(p.x - 1, p.y - 1))
		reference.append(Vector2(p.x + 1, p.y))
		reference.append(Vector2(p.x - 1, p.y))
		reference.append(Vector2(p.x, p.y + 1))
		reference.append(Vector2(p.x, p.y - 1))
		
	return coveredCells;
	pass ;
func getCellReferences(pos, turretRange, turret=null, cellPositions=[],sloppy=false):
	var mapPosition = getMapPositionNormalised(pos)
	#traversing from the top left corner to the bottom right corner

	mapPosition.x = mapPosition.x - turretRange;
	mapPosition.y = mapPosition.y - turretRange;
	var coveredCells = []

	#+1 because it needs to be an uneven number
	
	for y in range(turretRange * 2 + 1):
		for x in range(turretRange * 2 + 1):
			if sloppy||isProperCell(mapPosition.x + x, mapPosition.y + y):
				if isOutOfBounds(mapPosition.x + x, mapPosition.y + y):continue
				if turret!=null:
					var glob_ref_pos=getGlobalFromReference(Vector2(int(mapPosition.x+x),int(mapPosition.y+y)))
					if glob_ref_pos.distance_squared_to(pos)>turret.trueRangeSquared:
						continue
				#	if glob_ref_pos.distance_to(pos)>turretRange*Stats.block_size:
					#	continue
				coveredCells.append(map[mapPosition.y + y][mapPosition.x + x].ms)
				cellPositions.append(Vector2(mapPosition.x + x, mapPosition.y + y))
			
	return coveredCells;
	pass
func isProperCell(x, y):
	
	return not isOutOfBounds(x, y)# and (not isOccupiedCell(x, y))
	
func isOccupiedCell(x, y):
	for turret in Turret.turrets:
		if not is_instance_valid(turret): continue
		var pos = getMapPositionNormalised(turret.global_position)
		if pos.x == x&&pos.y == y:
			return true;
	return false;
	pass ;
func isOutOfBounds(x, y):
	if x >= gameState.board_width + 2 * 10||x < 0:
		return true
	if y >= map.size()||y < 0:
		return true
	return false
			
	pass
func addholders(row: Array):
	for i in range(gameState.board_width + 2 * 12):
		row.append(Holder.new())
	pass ;

class Holder:
	var ts = []
	var ms = []
	
	pass ;
