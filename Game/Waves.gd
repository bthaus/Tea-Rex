extends BaseEntity
class_name Spawner
var state:GameState
signal wave_done



var spawner_id;
var color: GameboardConstants.TileColor
var waves=[]
var waveMonsters=[]
static var grids:Array[grid_type_dto]=[]
var closest_target:Node2D
var targets=[]
var paths
var rnd = RandomNumberGenerator.new()

static var numMonstersActive=0;
var numReachedSpawn:float=0;
var numDied:float=0;
var numSpawned:float=0;
var _astar_id

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	state.start_build_phase.connect(func():
		if state.spawners.find(self)==-1:queue_free()
		)
	GameState.gameState.player_died.connect(func():
		for m in waveMonsters:
			if m != null:m.queue_free())
	

static func create(tile_id: int, map_layer: int, map_position:Vector2, spawner_id: int, color: GameboardConstants.TileColor)-> Spawner:
	var s=load("res://GameBoard/Spawner.tscn").instantiate() as Spawner;
	s.state=GameState.gameState;
	s.color=color
	s.spawner_id=spawner_id
	s.tile_id = tile_id
	s.map_layer = map_layer
	s.map_position = map_position
	
	GameState.gameState.spawners.push_back(s)
	GameState.gameState.add_child(s)
	return s
		
func start(wavenumber:int):
	
	if targets.is_empty():
		for t in state.targets:
			if t.color==color:
				targets.append(t)
	if targets.is_empty():
		util.p("For some reason this spawner doesnt have same colored targets. pls report to the police. ")
	start_wave(wavenumber)	
	pass;
func start_wave(number):
	for dto in waves[number]:
		for i in range(dto.count):
			numMonstersActive=numMonstersActive+1
			numSpawned=numSpawned+1
			waveMonsters.append(Monster.create(dto.monster_id,closest_target))
	doSpawnLogic()
	pass;	

func doSpawnLogic():
	var delay=0;
	var count = 0;
	for mo in waveMonsters:
		count = count + 1
		if count % 5 == 0: #Every 5th monster longer break
			delay = delay + 3
		else:
			delay = delay + rnd.randf_range(0.0,0.5) #Change for spawning time 
		get_tree().create_timer(0.5*delay).timeout.connect(spawnEnemy.bind(mo))
	util.p("im taking minions from the array and spawn them in a sensible way")
	pass;
	
func spawnEnemy(mo:Monster):

	mo.monster_died.connect(monsterDied)
	mo.reached_spawn.connect(monsterReachedSpawn)
	mo.global_position=global_position
	if paths==null:return
	for dto in paths:
		if mo.moving_type==dto.type:
			mo.path=dto.path
	GameState.gameState.get_node("MinionHolder").add_child(mo)
	

	pass;
func monsterReachedSpawn(monster:Monster):
	numReachedSpawn=numReachedSpawn+1;
	numMonstersActive=numMonstersActive-1;

	if numMonstersActive<=0:
		state.startBuildPhase()
		
	pass;	
func monsterDied(monster:Monster):
	numDied=numDied+1;
	numMonstersActive=numMonstersActive-1;
	
	if numMonstersActive==0:
		state.startBuildPhase()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	
	pass
func refresh_path(redo_grids=true):
	if redo_grids:
		_set_grids()
	paths= _get_paths(state.board,self)
	$drawpoint.paths=paths
	$drawpoint.queue_redraw()
	pass;	
static func refresh_all_paths(redo_grids=true):
	if redo_grids:
		_set_grids()
	for s in GameState.gameState.spawners:
		s.refresh_path(false)
	pass;	
static func can_all_reach_target(redo_grids=true):
	if redo_grids:
		_set_grids()
	for s in GameState.gameState.spawners:
		if not s.can_reach_target(): 	
			return false
	return true;
	pass;	
func can_reach_target():
	var paths=_get_paths(state.board,self)
	if paths==null:
		print("no reach")
		return false
	return true	
static func _get_paths(map:TileMap,spawner):
	var paths=[]
	if grids.is_empty():
		_set_grids()
	for grid in grids:
		var spawner_temp
		for s in grid.spawner_ids:
			if s.spawner==spawner:
				spawner_temp=s.astar_id
		var path=_get_shortest_path_global(grid,spawner_temp)
		if path.size()==0:
			return null
		var type=grid.type	
		if type==Monster.MonsterMovingType.GROUND:
			paths.append(path_color_type_dto.new(path,Color.WHITE,type))
		else:	
			print("readd drawing of flying minion path once we actually have some")	
			#paths.append(path_color_type_dto.new(path,Color.SKY_BLUE,type))
	
	return paths
static func _get_shortest_path_global(grid:grid_type_dto,spawner):
	var path=[]
	var shortest_path=10000000
	for base in grid.base_ids:
		var target=base.astar_id
		#if target.color!=spawner.color: continue
		var temp=grid.astar_grid.get_point_path(spawner,target)
		if temp.size()<shortest_path and temp.size()>0:
			shortest_path=temp.size()
			path=temp
	print(path.size())	
	var global_path=[]
	for cell in path:
		global_path.append(GameState.gameState.board.map_to_local(cell))
	return global_path
	pass;	
static func _set_grids():
	grids.clear()
	for type in Monster.MonsterMovingType.values():
		var astar=_get_astar_grid(GameState.gameState.board,type,GameState.gameState.spawners,GameState.gameState.targets)
		grids.append(astar)
	pass;	


	
static var _current_grid
static func get_point_id(x, y):
	return _current_grid[x][y]
	pass;	
static func _get_astar_grid(map:TileMap,monstertype:Monster.MonsterMovingType,froms,tos):
	var movable_cells=_get_movable_cells_per_monster_type(map,monstertype)

	var astar_grid=PortalStar.new()
	astar_grid.reserve_space(64*64)
	for y in range(0, Stats.LEVEL_EDITOR_HEIGHT): #Just put every possible tile in the array
				for x in range(0, Stats.LEVEL_EDITOR_WIDTH):
					if movable_cells[x][y]!=-1:
						astar_grid.add_point(movable_cells[x][y],Vector2(x,y))
	for y in range(movable_cells.size()):
		for x in range(movable_cells[y].size()):
			var point_id = get_point_id(x, y)
			if point_id != -1:
				_connect_with_neigbours(movable_cells,point_id,x,y,astar_grid)
				# Connect to the right neighbor
	var grid_type_dto=grid_type_dto.new(astar_grid,monstertype)				
	for from in froms:
		from._astar_id=astar_grid.get_available_point_id()
		astar_grid.add_point(from._astar_id,from.map_position)
		_connect_with_neigbours(movable_cells,from._astar_id,from.map_position.x,from.map_position.y,astar_grid)
		grid_type_dto.spawner_ids.append(spawner_astar_id_dto.new(from,from._astar_id))
	for to in tos:
		to._astar_id=astar_grid.get_available_point_id()
		astar_grid.add_point(to._astar_id,to.map_position)
		_connect_with_neigbours(movable_cells,to._astar_id,to.map_position.x,to.map_position.y,astar_grid)
		grid_type_dto.base_ids.append(base_astar_id_dto.new(to,to._astar_id))
	
	_register_portals(astar_grid,movable_cells)
	
	
	return grid_type_dto
	pass;
static func _register_portals(astar,movable_cells):
	for portal in GameState.gameState.portals:
		#var id=get_point_id(portal.map_position.x,portal.map_position.y)
		#if prevp!=-1:
			#astar.remove_point(prevp)
		var id=astar.get_available_point_id()
		astar.add_point(id,portal.map_position)
		_connect_with_neigbours(movable_cells,id,portal.map_position.x,portal.map_position.y,astar)
		for to_connect in GameState.gameState.portals:
			if portal==to_connect:continue
			if portal.group_id==to_connect.group_id:
				if portal.entry==Portal.ENTRY_TYPE.BIDIRECTIONAL and to_connect.entry==Portal.ENTRY_TYPE.BIDIRECTIONAL:
					_connect_portals(portal,to_connect,astar)
				elif portal.entry==Portal.ENTRY_TYPE.BIDIRECTIONAL and to_connect.entry==Portal.ENTRY_TYPE.OUT:
					_connect_portals(portal,to_connect,astar,false)
				elif portal.entry==Portal.ENTRY_TYPE.IN and to_connect.entry==Portal.ENTRY_TYPE.OUT:
					_connect_portals(portal,to_connect,astar,false)	
				
	pass;	
static func _connect_portals(portal,to_connect,astar,bi=true):
	astar.connect_points(get_point_id(portal.map_position.x,portal.map_position.y),get_point_id(to_connect.map_position.x,to_connect.map_position.y),bi)
	pass;	
#returns the smallest and largest point of a map as a rect2i 	
static func _connect_with_neigbours(movable_cells,point_id,x,y,astar_grid):
	if x + 1 < movable_cells[y].size():
				var right_id = get_point_id(x + 1, y)
				if right_id != -1:
					astar_grid.connect_points(point_id, right_id)
				# Connect to the bottom neighbor
				if y + 1 < movable_cells.size():
					var bottom_id = get_point_id(x, y + 1)
					if bottom_id != -1:
						astar_grid.connect_points(point_id, bottom_id)
				# Connect to the left neighbor
				if x - 1 >= 0:
					var left_id = get_point_id(x - 1, y)
					if left_id != -1:
						astar_grid.connect_points(point_id, left_id)
				# Connect to the top neighbor
				if y - 1 >= 0:
					var top_id = get_point_id(x, y - 1)
					if top_id != -1:
						astar_grid.connect_points(point_id, top_id)
	pass;

#returns an array of cells on which the given monster type can move.
static func _get_movable_cells_per_monster_type(map: TileMap, monstertype: Monster.MonsterMovingType):
		var cells: Array = []
		for i in range(Stats.LEVEL_EDITOR_HEIGHT):
			var arr=[]
			for x in range(0, Stats.LEVEL_EDITOR_WIDTH):
				arr.append(-1)
			cells.append(arr)
		var id=0
		match(monstertype):
			Monster.MonsterMovingType.GROUND:
				for pos in map.get_used_cells(GameboardConstants.GROUND_LAYER):
					id=id+1;
					if GameboardConstants.get_tile_type(map, GameboardConstants.GROUND_LAYER, pos) != GameboardConstants.TileType.GROUND: #It is not a ground, ignore
						continue
					
					if map.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos) == -1: #Block layer is free
						cells[pos.x][pos.y]=id
					
			Monster.MonsterMovingType.AIR:
				for y in range(0, Stats.LEVEL_EDITOR_HEIGHT): #Just put every possible tile in the array
					for x in range(0, Stats.LEVEL_EDITOR_WIDTH):
						id=id+1;
						cells[x][y]=id
		_current_grid=cells
		return cells
		
	

func _on_button_mouse_entered():
	var percentage
	var Risnull=numReachedSpawn==0
	var Sisnull=numSpawned==0;
	
	if Risnull or Sisnull:
		percentage="0"
	else:
		var p=(numReachedSpawn/ numSpawned)
		percentage=str(int(p*100))
	#state.menu.showDescription(percentage+"% of minions spawned reached your base. ")
	pass # Replace with function body.


func _on_button_mouse_exited():
	#state.menu.hideDescription()
	pass # Replace with function body.
class grid_type_dto:
	var astar_grid:AStar2D
	var type
	var spawner_ids:Array[spawner_astar_id_dto]=[]
	var base_ids:Array[base_astar_id_dto]=[]
	var portal_ids:Array[portal_astar_id_dto]=[]
	
	func _init(grid,t):
		self.astar_grid=grid
		self.type=t
class spawner_astar_id_dto:
	var spawner:Spawner
	var astar_id:int
	func _init(s,id):
		self.spawner=s
		self.astar_id=id
class base_astar_id_dto:
	var base:PlayerBase
	var astar_id:int	
	func _init(s,id):
		self.base=s
		self.astar_id=id
class portal_astar_id_dto:
	var portal
	var astar_id:int	
	func _init(s,id):
		self.portal=s
		self.astar_id=id				
class path_color_type_dto:
	var path=[]
	var color:Color
	var type
	func _init(path,color,type):
		self.path=path
		self.color=color
		self.type=type	
