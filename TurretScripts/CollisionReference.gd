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
	oldx=normaliseX(x)
	x=normaliseX(x)
	y=normaliseY(y)
	oldy=normaliseY(y)
	print("minion:" + str(x) + ", "+str(y))
	map[oldy][oldx].ms.erase(m)
	map[y][x].ms.push_back(m)
	#rowCounter[oldy]=rowCounter[oldy]-1
	#rowCounter[y]=rowCounter[y]+1
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
func initialise(g):
	gameState=g
	instance=self;
	
	for i in range(gameState.board_height):
		addRow(map)
	pass;
func addRows():
	for i in range(gameState.board_height-map.size()):
		addRow(map)
	pass;
func addRow(y:Array):
	var row=[]
	addholders(row)
	y.append(row)
	rowCounter.append(0)
	pass;
		
		
func addholders(row:Array):
	for i in range(gameState.board_width+2*10):
		row.append(Holder.new())
	pass;
static var cacheSize=100;
class Holder:
	var ts=[]
	var ms=[]
	
	pass;




