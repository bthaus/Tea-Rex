extends Node
class_name CollisionReference

var gameState:GameState
var map=[];
var rowCounter=[]
static var instance;
static func normaliseX(x):
	return x+9;
static func normaliseY(y):
	return y-1;	
	
static func normaliseVector(pos):
	return Vector2(normaliseX(pos.x),normaliseY(pos.y))
	pass;	
func removeMonster(mo):
	var pos=normaliseVector(instance.gameState.board.local_to_map(mo.global_position));
	map[pos.y][pos.x].ms.erase(mo)
	pass;	
func setMinion(oldx,oldy,x,y,m:Monster):
	oldx=normaliseX(oldx)
	x=normaliseX(x)
	y=normaliseY(y)
	oldy=normaliseY(oldy)
	
	map[oldy][oldx].ms.erase(m)
	map[y][x].ms.push_back(m)
	if oldy!=y:
		rowCounter[oldy]=rowCounter[oldy]-1
		rowCounter[y]=rowCounter[y]+1
		
	
	
	pass;
func get_monster(pos):
	
	pos.x=normaliseX(pos.x)
	pos.y=normaliseY(pos.y)
	
	#if rowCounter[pos.y-1]>0:
	if map[pos.y][pos.x].ms.size()>0:
		
		var mo=map[pos.y][pos.x].ms.back()
		return mo
		#return map[pos.y][pos.x].ms[0]
	#map[pos.y][pos.x].ms	
	return null;		
	pass;	
func getMapPositionNormalised(pos):
	pos=gameState.board.local_to_map(pos)
	return normaliseVector(pos)
	pass;	
func initialise(g):
	gameState=g
	instance=self;
	Turret.collisionReference=self;
	gameState.get_node("MinionHolder").reference=self;
	gameState.get_node("BulletHolder").reference=self;
	gameState.collisionReference=self;
	
	for i in range(gameState.board_height):
		addRow(map)
	pass;
func addRows():
	for i in range(gameState.board_height+10-map.size()):
		addRow(map)
	pass;
func addRow(y:Array):
	var row=[]
	addholders(row)
	y.append(row)
	rowCounter.append(0)
	rowCounter.append(0)
	pass;
func getMinionsAroundPosition(pos):
	var cells=getNeighbours(pos);
	pos=getMapPositionNormalised(pos)
	cells.append(map[pos.y][pos.x].ms)
	var minions=[]
	for ms in cells:
		minions.append_array(ms)
	return minions
	pass;	
	
func clearUp():
	for y in map:
		for x in y:
			x.ms.clear()
	pass;	
func getNeighbours(pos):
	var p=getMapPositionNormalised(pos)
	var coveredCells=[]
	coveredCells.append(map[p.y+1][p.x+1].ms)
	coveredCells.append(map[p.y-1][p.x+1].ms)
	coveredCells.append(map[p.y+1][p.x-1].ms)
	coveredCells.append(map[p.y-1][p.x-1].ms)
	coveredCells.append(map[p.y+1][p.x].ms)
	coveredCells.append(map[p.y-1][p.x+1].ms)
	coveredCells.append(map[p.y][p.x+1].ms)
	coveredCells.append(map[p.y][p.x-1].ms)
	return coveredCells;
	pass;	
func getCellReferences(pos, turretRange,turret):
	var mapPosition=getMapPositionNormalised(pos)
	#traversing from the top left corner to the bottom right corner
	print(mapPosition)
	mapPosition.x=mapPosition.x-turretRange;
	mapPosition.y=mapPosition.y-turretRange;
	var coveredCells=[]
	turret.rowcounterstart=mapPosition.y
	turret.rowcounterend=mapPosition.y*2+1
	#+1 because it needs to be an uneven number
	
	for y in range(turretRange*2+1):
		for x in range(turretRange*2+1):
			if isProperCell(mapPosition.x+x,mapPosition.y+y):
				coveredCells.append(map[mapPosition.y+y][mapPosition.x+x].ms)
			
	return coveredCells;
	pass	
func isProperCell(x,y):
	return (not isOutOfBounds(x,y) )and(not isOccupiedCell(x,y))
	
func isOccupiedCell(x,y):
	for turret in Turret.turrets:
		if not is_instance_valid(turret):continue
		var pos=getMapPositionNormalised(turret.global_position)
		if pos.x==x&&pos.y==y:
			return true;
	return false;
	pass;		
func isOutOfBounds(x,y):
	if x>=gameState.board_width+2*10||x<0:
		return true
	if y>=map.size()||y<0:
		return true
	return false	
			
	pass		
func addholders(row:Array):
	for i in range(gameState.board_width+2*10):
		row.append(Holder.new())
	pass;
static var cacheSize=100;
class Holder:
	var ts=[]
	var ms=[]
	
	pass;




