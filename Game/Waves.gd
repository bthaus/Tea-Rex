extends BaseEntity
class_name Spawner
var state:GameState
signal wave_done



var spawner_id;
var color: GameboardConstants.TileColor
var waves=[]
var waveMonsters=[]
static var grids:Array[grid_type_dto]=[]
static var invisible_grids:Array[grid_type_dto]=[]
static var all_movement_types:Array[Array]=[]
var spawning_movement_types:Array[Array]=[]

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
	

static func create(tile_id: int, map_layer: GameboardConstants.MapLayer, map_position:Vector2, spawner_id: int, color: GameboardConstants.TileColor)-> Spawner:
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
	var delay=1;
	var count = 0;
	for mo in waveMonsters:
		count = count + 1
		if !util.valid(mo):continue
		#spawnEnemy(mo)
		get_tree().create_timer(0.5*count*rnd.randf_range(0.0,1.5)).timeout.connect(spawnEnemy.bind(mo))
		#if count % 5 == 0: #Every 5th monster longer break
			#delay = delay + 3
		#else:
			#delay = delay + rnd.randf_range(0.0,0.5) #Change for spawning time 
		#get_tree().create_timer(0.5*count).timeout.connect(spawnEnemy.bind(mo))
	
	pass;
	
func spawnEnemy(mo:Monster):
	if not _is_simulation:
		mo.monster_died.connect(monsterDied)
		mo.reached_spawn.connect(monsterReachedSpawn)
	mo.global_position=global_position
	mo.spawner_color=color
	mo.spawner=self
	if paths==null:return
	for dto in paths:
		var satisfied=true;
		for type in mo.core.movable_cells:
			if !dto.type.has(type):
				satisfied=false;
				continue
		if satisfied:
			mo.path=dto.path
			break;
	if mo.path.is_empty():
		print("monster without path")
				
	GameState.gameState.get_node("MinionHolder").add_child(mo)
	

	pass;
func initialise():
	spawning_movement_types.clear()
	for dto in waves:
		for monster in dto:
			if monster.count==0:continue
			var m=Monster.create(monster.monster_id)
			var match_found=false
			for types in spawning_movement_types:
				var current_satisfied=true
				for type in m.core.movable_cells:
					if !types.has(type):
						current_satisfied=false;
				if current_satisfied: 
					match_found=true
					break;
			if !match_found:
				spawning_movement_types.append(m.core.movable_cells.duplicate())
			m.queue_free()
	#iterate through all local types			
	for types in spawning_movement_types:
		var satisfied=false
		#for each local typetuple, go trough all global typetuples	
		for i_arr in all_movement_types:
			var current_satisfied=true
			#for each type of current local typetuple, check current global typetuple
			for type in types:
				if !i_arr.has(type):
					#if a missmatch has been found, break and mark false
					current_satisfied=false;
					break;	
			#if all types have been found in current tuple, mark true and break		
			if current_satisfied:
				satisfied=true
				break	
		#if no satisfactory tuple has been found, append current local tuple to global tuple		
		if !satisfied:
			all_movement_types.append(types)			
	pass;	
var _is_simulation=false;	
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



static func get_new_path(monster:Monster):
	var from=monster.global_position
	var to=monster.path.back()
	
	var grid:grid_type_dto
	
	for dto in grids:
		var satisfied=true;
		for type in monster.core.movable_cells:
			if !dto.type.has(type):
				satisfied=false;
				continue
		if satisfied:
			grid=dto
			break;	
			
	for dto in invisible_grids:
		var satisfied=true;
		for type in monster.core.movable_cells:
			if !dto.type.has(type):
				satisfied=false;
				continue
		if satisfied:
			grid=dto
			break;	
						
	if grid==null:
		grid=_get_astar_grid(GameState.board,monster.core.movable_cells,GameState.spawners,GameState.gameState.targets)
		invisible_grids.append(grid)
		
	var from_id=GameState.board.local_to_map(from)
	from_id=grid.get_point_id(from_id.x,from_id.y)
	var path
	var length=99999
	for t in grid.base_ids:
		if t.base.color==monster.spawner_color:
			var temp=grid.astar_grid.get_point_path(from_id,t.astar_id)	
			if temp.size()<length:
				path=temp
				length=path.size()
	var global_path=[]
	for cell in path:
		global_path.append(GameState.gameState.board.map_to_local(cell))
	return global_path			
	
	
func refresh_path(redo_grids=true):
	if redo_grids:
		_set_grids()
		
	paths= get_paths(state.board,self)
	$drawpoint.paths=paths
	$drawpoint.queue_redraw()
	pass;	
static func refresh_all_paths(redo_grids=true):
	if redo_grids:
		_set_grids()
	
	for s in GameState.gameState.spawners:
		s.refresh_path(false)
	update_damage_estimate()
		
	pass;
static func update_damage_estimate():
	var total_average_damage=0	
	for s in GameState.gameState.spawners:
		total_average_damage+=s.get_average_path_damage()
	GameState.gameState.current_expected_damage=total_average_damage	
	pass;	
func get_average_path_damage():
	var total_damage=0
	if paths==null: return 0
	for path in paths:
		var turrets=GameState.gameState.collisionReference.get_covering_turrets_from_path(path.path)
		#for turret in turrets:
			#if turret.base.targetable_enemy_types.has(path.type):
				##total_damage+=turret.base.get_average_damage()
	return total_damage			
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
	var paths=get_paths(state.board,self)
	if paths==null:
		print("no reach")
		return false
	return true	
static func get_paths(map:TileMap,spawner):
	var paths=[]
	if grids.is_empty():
		_set_grids()
	for grid in grids:
		var spawner_temp
		for s in grid.spawner_ids:
			if s.spawner==spawner:
				spawner_temp=s.astar_id
		
		var satisfied=false
		for types in spawner.spawning_movement_types:
			satisfied=true
			for type in types:
				if not grid.type.has(type):
					satisfied=false
					continue
			if satisfied:
				break
		if not satisfied:
			continue			
		
				
		var path=_get_shortest_path_global(grid,spawner_temp)
		if path.size()==0:
			return null
		var type=grid.type	
		if type.has(Monster.MonsterMovingType.GROUND):
			paths.append(path_color_type_dto.new(path,Color.WHITE,type))
		else:	
			paths.append(path_color_type_dto.new(path,Color.SKY_BLUE,type))
	if paths.is_empty():return null
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
	var global_path=[]
	for cell in path:
		global_path.append(GameState.gameState.board.map_to_local(cell))
	return global_path
	pass;	
static func _set_grids():
	grids.clear()
	for type in all_movement_types:
		var astar=_get_astar_grid(GameState.gameState.board,type,GameState.gameState.spawners,GameState.gameState.targets)
		grids.append(astar)
	pass;	


	
static var _current_grid
static func get_point_id(x, y):
	return _current_grid[x][y].id
	pass;	
static func _get_astar_grid(map:TileMap,monstertype:Array[Monster.MonsterMovingType],froms,tos):
	var movable_cells=_get_movable_cells_per_monster_type(map,monstertype)
	var astar_grid=PortalStar.new()
	astar_grid.reserve_space(GameboardConstants.BOARD_WIDTH * GameboardConstants.BOARD_HEIGHT)
	for y in range(0, GameboardConstants.BOARD_HEIGHT): #Just put every possible tile in the array
				for x in range(0, GameboardConstants.BOARD_WIDTH):
					if movable_cells[x][y].id!=-1:
						astar_grid.add_point(movable_cells[x][y].id,Vector2(x,y),movable_cells[x][y].weight)
	for y in range(movable_cells.size()):
		for x in range(movable_cells[y].size()):
			var point_id = get_point_id(x, y)
			if point_id != -1:
				_connect_with_neigbours(movable_cells,point_id,x,y,astar_grid)
				# Connect to the right neighbor
	var grid_type_dto=grid_type_dto.new(astar_grid,monstertype)	
	grid_type_dto.id_array=movable_cells			
	for from in froms:
		from._astar_id=astar_grid.get_available_point_id()
		grid_type_dto.id_array[from.map_position.x][from.map_position.y]=astar_id_weight_dto.new(from._astar_id)
		astar_grid.add_point(from._astar_id,from.map_position)
		_connect_with_neigbours(movable_cells,from._astar_id,from.map_position.x,from.map_position.y,astar_grid)
		grid_type_dto.spawner_ids.append(spawner_astar_id_dto.new(from,from._astar_id))
	for to in tos:
		to._astar_id=astar_grid.get_available_point_id()
		grid_type_dto.id_array[to.map_position.x][to.map_position.y]=astar_id_weight_dto.new(to._astar_id)
		
		astar_grid.add_point(to._astar_id,to.map_position)
		_connect_with_neigbours(movable_cells,to._astar_id,to.map_position.x,to.map_position.y,astar_grid)
		grid_type_dto.base_ids.append(base_astar_id_dto.new(to,to._astar_id))
	
	_register_portals(astar_grid,movable_cells)
	
	
	return grid_type_dto

static func _register_portals(astar,movable_cells):
	var portals=GameState.gameState.portals
	for portal in portals:
		var id=astar.get_available_point_id()
		astar.add_point(id,portal.map_position)
		_current_grid[portal.map_position.x][portal.map_position.y]=astar_id_weight_dto.new(id)
		_connect_with_neigbours(movable_cells,id,portal.map_position.x,portal.map_position.y,astar)
		
	for portal in portals:
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
	var a =get_point_id(portal.map_position.x,portal.map_position.y)
	var b =get_point_id(to_connect.map_position.x,to_connect.map_position.y)
	astar.connect_points(a,b,bi)
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
static func _get_movable_cells_per_monster_type(map: TileMap, monstertypes: Array[Monster.MonsterMovingType]):
		var reference=GameState.collisionReference
		var cells: Array = []
		for i in range(GameboardConstants.BOARD_HEIGHT):
			var arr=[]
			for x in range(0, GameboardConstants.BOARD_WIDTH):
				arr.append(astar_id_weight_dto.new(-1))
				
			cells.append(arr)
		var id=0
		var preview_pos_arr=[]
		if GameState.gameState.gameBoard!=null:	
			var previews=GameState.gameState.gameBoard.preview_turrets
			
			if previews!=null:
				for p in previews:
					preview_pos_arr.append(p.get_map())
			
		
		if monstertypes.has(Monster.MonsterMovingType.AIR):
			for y in range(0, GameboardConstants.BOARD_HEIGHT): #Just put every possible tile in the array
				for x in range(0, GameboardConstants.BOARD_WIDTH):
					id=id+1;
					if reference.can_move_type(Vector2(x,y),monstertypes):
						var lowest=1000
						for monstertype in monstertypes:
							var weight=reference.get_weight_from_cell(Vector2(x,y),monstertype)
							if weight<lowest:
								lowest=weight
						cells[x][y]=astar_id_weight_dto.new(id,lowest)
		else:
			for pos in map.get_used_cells(GameboardConstants.MapLayer.GROUND_LAYER):
				if preview_pos_arr.has(pos):continue
				id=id+1;
				
				if reference.can_move_type(pos,monstertypes):
					var lowest=1000
					for monstertype in monstertypes:
						var weight=reference.get_weight_from_cell(pos,monstertype)
						if weight<lowest:
							lowest=weight
					cells[pos.x][pos.y]=astar_id_weight_dto.new(id,lowest)
								
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
	var id_array
	func get_point_id(x, y):
		return id_array[x][y].id
		
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
class astar_id_weight_dto:
	var weight:float
	var id:int		
	func _init(i,w=1):
		weight=w
		id=i
class path_color_type_dto:
	var path=[]
	var color:Color
	var type
	func _init(path,color,type):
		self.path=path
		self.color=color
		self.type=type	
