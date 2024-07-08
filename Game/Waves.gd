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
	targets=state.targets
	paths= _get_paths(targets,state.board,self)
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
		var paths=s.get_paths(s.targets,s.state.board,s)
		if paths==null:
			return false
	return true;
	pass;	
func can_reach_target():
	
	var paths=_get_paths(targets,state.board,self)
	if paths==null:
		print("no reach")
		return false
	return true	
static func _get_paths(targets:Array, map:TileMap,spawner):
	var paths=[]
	if grids.is_empty():
		_set_grids()
	for grid in grids:
		var path=_get_shortest_path_global(grid,targets,spawner)
		if path.size()==0:
			return null
		var type=grid.type	
		if type==Monster.MonsterMovingType.GROUND:
			paths.append(path_color_type_dto.new(path,Color.WHITE,type))
		else:		
			paths.append(path_color_type_dto.new(path,Color.SKY_BLUE,type))
	
	return paths
static func _get_shortest_path_global(grid:grid_type_dto,targets,spawner):
	var path=[]
	var shortest_path=10000000
	for target in targets:
		#if target.color!=spawner.color: continue
		var temp=grid.astar_grid.get_id_path(spawner.map_position,target.map_position)
		if temp.size()<shortest_path:
			shortest_path=temp.size()
			path=temp
	var global_path=[]
	for cell in path:
		global_path.append(GameState.gameState.board.map_to_local(cell))
	return global_path
	pass;	
static func _set_grids():
	grids.clear()
	for type in Monster.MonsterMovingType.values():
		var astar:AStarGrid2D=_get_astar_grid(GameState.gameState.board,type,GameState.gameState.spawners,GameState.gameState.targets)
		grids.append(grid_type_dto.new(astar,type))
	pass;	
static func _get_path_of_traveltype(targets:Array, map:TileMap,spawner,monstertype:Monster.MonsterMovingType):
	var path=[]
	var shortest_path=10000000
	
	
	#for target in targets:
		##var temp=astar.get_id_path(spawner.map_position,target.map_position)
		#if temp.size()<shortest_path:
			#shortest_path=temp.size()
			#path=temp
	
	var global_path=[]
	for pos in path:
		global_path.append(map.map_to_local(pos))
	return global_path
	pass;
#
static func _get_astar():
	return AStarGrid2D.new()
	pass;
static func _get_astar_grid(map:TileMap,monstertype:Monster.MonsterMovingType,froms,tos)-> AStarGrid2D:
	var movable_cells=_get_movable_cells_per_monster_type(map,monstertype)
	var map_square=_get_map_square(map)
	var astar_grid=_get_astar()
	astar_grid.region=map_square
	astar_grid.update()
	astar_grid.diagonal_mode=1
	astar_grid.fill_solid_region(map_square)
	
	for movable in movable_cells:
		astar_grid.set_point_solid(movable,false)
	for from in froms:
		astar_grid.set_point_solid(from.map_position,false)
	for to in tos:
		astar_grid.set_point_solid(to.map_position,false)
	return astar_grid
	pass;
#returns the smallest and largest point of a map as a rect2i 	

static func _get_map_square(map):
	var smallest=Vector2(0,0)
	var biggest=Vector2(Stats.LEVEL_EDITOR_WIDTH,Stats.LEVEL_EDITOR_HEIGHT)
	return Rect2i(smallest.x,smallest.y,biggest.x,biggest.y)
	pass;	
#returns an array of cells on which the given monster type can move.
static func _get_movable_cells_per_monster_type(map: TileMap, monstertype: Monster.MonsterMovingType)->Array[Vector2i]:
		var cells: Array[Vector2i] = []
		match(monstertype):
			Monster.MonsterMovingType.GROUND:
				for pos in map.get_used_cells(GameboardConstants.GROUND_LAYER):
					if GameboardConstants.get_tile_type(map, GameboardConstants.GROUND_LAYER, pos) != GameboardConstants.TileType.GROUND: #It is not a ground, ignore
						continue
					
					if map.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos) == -1: #Block layer is free
						cells.append(pos)
					
			Monster.MonsterMovingType.AIR:
				for y in range(0, Stats.LEVEL_EDITOR_HEIGHT): #Just put every possible tile in the array
					for x in range(0, Stats.LEVEL_EDITOR_WIDTH):
						cells.append(Vector2i(x, y))
		
		return cells
		
func _draw():
	return
	targets=state.targets
	var paths = _get_paths(targets,state.board,self)
	if paths ==null:
		
		return
	#lightened makes the line glow. for some reason this makes aqua and red the exact other color. i have no clue	
	var color = Color.RED 
	color=color.lightened(8)
	for path in paths:
		for i in range(1, path.size()):
			$drawpoint.draw_line(Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y),
			Vector2(path[i].x - global_position.x, path[i].y - global_position.y), color, 3, true)
			

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
	var astar_grid:AStarGrid2D
	var type
	func _init(grid,t):
		self.astar_grid=grid
		self.type=t
	
class path_color_type_dto:
	var path=[]
	var color:Color
	var type
	func _init(path,color,type):
		self.path=path
		self.color=color
		self.type=type	
