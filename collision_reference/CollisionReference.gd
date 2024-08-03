extends GameObject2D
class_name CollisionReference

var gameState: GameState
var map = [];
var rowCounter = []
var bases=[]
static var instance;
static func normaliseX(x):
	return x
	return x + 9;
static func normaliseY(y):
	return y
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
	trigger_minion(Vector2(x,y),m)
	map[oldy][oldx].ms.erase(m)
	for base in bases:
		if x==base.x and y==base.y:
			gameState.hit_base(m)
			return;
	map[y][x].ms.push_back(m)
	
	pass ;
	
func getMapFromReference(pos):
	return pos
	return Vector2(pos.x - 9, pos.y + 1)
func getGlobalFromReference(pos):
	return GameState.gameState.board.map_to_local(getMapFromReference(pos))
	pass ;
func hit_wall(pos):
	pos.x = normaliseX(pos.x)
	pos.y = normaliseY(pos.y)
	return map[pos.y][pos.x].collides_with_bullets
		
func get_monster(pos):
	
	pos.x = normaliseX(pos.x)
	pos.y = normaliseY(pos.y)
	
	#if rowCounter[pos.y-1]>0:
	if isOutOfBoundsVector(pos):return
	if map[pos.y][pos.x].ms.size() > 0:
		
		var mo = map[pos.y][pos.x].ms.back()
		return mo
		#return map[pos.y][pos.x].ms[0]
	#map[pos.y][pos.x].ms	
	return null;
	pass ;
func get_monsters_at_pos(pos):
	var n=getMapPositionNormalised(pos)
	if not isOutOfBoundsVector(n):
		return map[n.y][n.x].ms
	else: return []	
func getMapPositionNormalised(pos):
	pos = gameState.board.local_to_map(pos)
	return normaliseVector(pos)
	pass ;
func initialise(g,map_dto):
	gameState = g
	instance = self;
	Turret.collisionReference = self;
	gameState.get_node("MinionHolder").reference = self;
	gameState.get_node("BulletHolder").reference = self;
	gameState.collisionReference = self;
	map=[]
	bases.clear()
	for i in range(GameboardConstants.BOARD_HEIGHT+12):
		addRow(map)
	for entity in map_dto.entities:
		map[normaliseY(entity.map_y)][normaliseX(entity.map_x)].collides_with_bullets=entity.collides_with_bullets	
		if entity.collides_with_bullets:
			print("colliding bro")	
	pass ;

func addRow(y: Array):
	var row = []
	addholders(row)
	y.append(row)
	
	pass ;
	
func registerBase(base):
	var pos=getMapPositionNormalised(base.global_position)
	bases.append(pos)
	pass;	
func getMinionsAroundPosition(pos):
	var cells = getNeighbours(pos);
	pos = getMapPositionNormalised(pos)
	if isOutOfBounds(pos.x,pos.y):return [];
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
		reference.append(Vector2(p.x, p.y + 1))
		reference.append(Vector2(p.x + 1, p.y + 1))
		reference.append(Vector2(p.x + 1, p.y))
		reference.append(Vector2(p.x + 1, p.y - 1))
		reference.append(Vector2(p.x, p.y - 1))
		reference.append(Vector2(p.x - 1, p.y - 1))
		reference.append(Vector2(p.x - 1, p.y))
		reference.append(Vector2(p.x - 1, p.y + 1))
		
		
		
		
		
		
		
	return coveredCells;
	pass ;
func register_turret(turret,placed):
	var pos=getMapPositionNormalised(turret.global_position)
	if placed:map[pos.y][pos.x].turret=turret
	
	for cell in turret.base.referenceCells:
		map[cell.y][cell.x].covering_turrets.append(turret)
	pass;
func unregister_turret(turret,placed):
	var pos=getMapPositionNormalised(turret.global_position)
	if placed:map[pos.y][pos.x].turret=null
	for cell in turret.base.referenceCells:
		map[cell.y][cell.x].covering_turrets.erase(turret)
	pass;	
func get_turret_from_global(pos):
	var ref= getMapPositionNormalised(pos)
	if isOutOfBounds(ref.x,ref.y): return
	return map[ref.y][ref.x].turret
func get_turret_from_board(pos):
	var ref=normaliseVector(pos)
	if isOutOfBounds(ref.x,ref.y): return
	return map[ref.y][ref.x].turret
	pass;			
func getCellReferences(pos, turretRange, turret=null, cellPositions=[],ignore_obstacles=false):
	var mapPosition = getMapPositionNormalised(pos)
	#traversing from the top left corner to the bottom right corner

	mapPosition.x = mapPosition.x - turretRange;
	mapPosition.y = mapPosition.y - turretRange;
	var coveredCells = []

	#+1 because it needs to be an uneven number
	
	#for y in range(turretRange * 2 + 1):
		#for x in range(turretRange * 2 + 1):
			#if isProperCell(mapPosition.x + x, mapPosition.y + y):
				#if isOutOfBounds(mapPosition.x + x, mapPosition.y + y):continue
				#if turret!=null:
					#var glob_ref_pos=getGlobalFromReference(Vector2(int(mapPosition.x+x),int(mapPosition.y+y)))
					#if glob_ref_pos.distance_squared_to(pos)>turret.trueRangeSquared:
						#continue
				#coveredCells.append(Vector2(mapPosition.x + x, mapPosition.y + y))
	#if not ignore_obstacles:
	var range_squared
	if turret!=null:
		range_squared=turret.trueRangeSquared
	else:
		range_squared=turretRange*GameboardConstants.TILE_SIZE
		range_squared*=range_squared	
	coveredCells=add_cells(cellPositions,pos,turret,ignore_obstacles,range_squared)
	var ret=[]
	for cell in coveredCells:
		if ignore_obstacles:
			ret.append(map[cell.y][cell.x].ms)
			cellPositions.append(cell)
		elif !map[cell.y][cell.x].collides_with_bullets:
			ret.append(map[cell.y][cell.x].ms)
			cellPositions.append(cell)	
	return ret;
	pass
static var movables=[]	
func add_cells(coveredCells,midpoint,turret,ignores_obstacles,range):
	
	var precision=25
	
	if turret!=null:
		precision=turret.range_precision
	var offsets=[]	
	for i in range(precision):
		var v=Vector2(10,0)
		v=util.rotate_vector(v,360/precision*i)
		offsets.append(v)
	var eval=[]		
	for offset in offsets:
		var base_vec=midpoint
		var collided=false;
		while(not isOutOfBoundsVector(getMapPositionNormalised(base_vec))):
			base_vec=base_vec+offset
			if (base_vec-midpoint).length_squared()>range:
				break;
			var p=getMapPositionNormalised(base_vec)
			if map[p.y][p.x].collides_with_bullets and !ignores_obstacles:
				collided=true
				break;
			if !collided and !eval.has(p):
				eval.append(p)
	
	
	return eval		
	pass;	
func get_cells_around_pos(glob,range,collides)->Array[Holder]:
	var pos=getMapPositionNormalised(glob)
	var vecs=[]
	add_cells(vecs,pos,null,collides,range)
	var cells:Array[Holder]=[]
	for v in vecs:
		cells.append(map[v.y][v.x])
	return cells
	pass;
func get_cell_at_map_pos(pos):
	return map[pos.y][pos.x]		
func get_random_turret_in_range(global_position,range,collides):
	var midpoint=global_position
	var precision=25
	var offsets=[]	
	
	range*=GameboardConstants.TILE_SIZE
	range*=range
	for i in range(precision):
		var v=Vector2(10,0)
		v=util.rotate_vector(v,360/precision*i)
		offsets.append(v)
	offsets.shuffle()	
	for offset in offsets:
		var base_vec=midpoint
		var collided=false;
		while(not isOutOfBoundsVector(getMapPositionNormalised(base_vec))):
			base_vec=base_vec+offset
			if (base_vec-midpoint).length_squared()>range:
				break;
			var p=getMapPositionNormalised(base_vec)
			if map[p.y][p.x].collides_with_bullets and collides:
				collided=true
				break;
			if !collided and map[p.y][p.x].turret!=null:
				return map[p.y][p.x].turret
	return null			
	
	pass;	
func isOutOfBoundsVector(pos):
	return isOutOfBounds(pos.x,pos.y)
	pass;	
func trigger_bullet(bullet:Projectile):
	var p=bullet.get_reference()
	for entity in map[p.y][p.x].entities:
		map[p.y][p.x].entity.trigger_bullet(bullet)
	pass;
func trigger_minion(p,minion:Monster):
	for entity in map[p.y][p.x].entities:
		#if !entity.has_method("trigger_minion"):continue
		entity.trigger_minion(minion)
	pass;		
func isProperCell(x, y):
	
	return not isOutOfBounds(x, y)# and (not isOccupiedCell(x, y))
func register_entity(entity:BaseEntity):
	var pos=normaliseVector(entity.map_position)
	
	var glob=entity.get_global()
	var ref=entity.get_reference()
	var glob_to_map=GameState.board.local_to_map(glob)
	map[pos.y][pos.x].entities.append(entity)
	_trigger_monsters_for_entity_at_pos(entity,entity.get_global())
	pass;	
func _trigger_monsters_for_entity_at_pos(entity,pos):
	var monsters=get_monsters_at_pos(pos)
	for m in monsters:
		trigger_minion(getMapPositionNormalised(pos),m)
	pass;	
func remove_entity(entity:BaseEntity):
	var pos=entity.get_reference()
	map[pos.y][pos.x].entities.erase(entity)
	pass
func register_entity_at_position(entitity:BaseEntity,glob):
	var pos=getMapPositionNormalised(glob)
	if isOutOfBoundsVector(pos):return
	map[pos.y][pos.x].entities.push_back(entitity)
	_trigger_monsters_for_entity_at_pos(entitity,glob)
	pass;	
func remove_entity_from_position(entity:BaseEntity,glob):
	var pos=getMapPositionNormalised(glob)
	if isOutOfBoundsVector(pos):return
	map[pos.y][pos.x].entities.erase(entity)		
func get_entities(pos):
	var p=getMapPositionNormalised(pos)
	return map[p.y][p.x].entities
	pass;	
func isOccupiedCell(x, y):
	for turret in Turret.turrets:
		if not is_instance_valid(turret): continue
		var pos = getMapPositionNormalised(turret.global_position)
		if pos.x == x&&pos.y == y:
			return true;
	return false;
	pass ;
func isOutOfBounds(x, y):
	if x >= GameboardConstants.BOARD_HEIGHT+11||x < 0:
		return true
	if y >= GameboardConstants.BOARD_WIDTH+11||y < 0:
		return true
	return false
			
	pass
func addholders(row: Array):
	for i in range(GameboardConstants.BOARD_WIDTH+12):
		row.append(Holder.new())
	pass ;

func register_path_cell_in_turrets(glob_pos):
	var pos=getMapPositionNormalised(glob_pos)
	for turret in map[pos.y][pos.x].covering_turrets:
		turret.register_path(map[pos.y][pos.x].ms)
	pass;
func get_covering_turrets_from_path(path):
	var turrets=[]
	for cell in path:
		var pos=getMapPositionNormalised(cell)
		turrets.append_array(map[pos.y][pos.x].covering_turrets)
	return turrets	
	pass;
class Holder:
	var turret
	var ms = []
	var covering_turrets=[]
	var collides_with_bullets=false;
	var entities=[]
	var entity:BaseEntity
	
	pass ;
