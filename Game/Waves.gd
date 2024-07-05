extends BaseEntity
class_name Spawner
var state:GameState
signal wave_done



var spawner_id;
var color: GameboardConstants.TileColor
var waves=[]
var waveMonsters=[]

var closest_target:Node2D
var targets=[]

var rnd = RandomNumberGenerator.new()

static var numMonstersActive=0;
var numReachedSpawn:float=0;
var numDied:float=0;
var numSpawned:float=0;

@onready var nav: NavigationAgent2D = $NavigationAgent2D
# Called when the node enters the scene tree for the first time.
func _ready():
	#nav.path_changed.connect(queue_redraw)
	state.start_build_phase.connect(func():
		if state.spawners.find(self)==-1:queue_free()
		)
	GameState.gameState.player_died.connect(func():
		for m in waveMonsters:
			if m != null:m.queue_free())
	#nav.target_position = closest_target.global_position

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
	mo.path=get_paths(targets,state.board,self,Stats.Monstertype.REGULAR)
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
	
	nav.get_next_path_position()
	
	##queue_redraw()
	
func can_reach_target():
	return nav.is_target_reachable()
	
static func get_paths(targets:Array, map:TileMap,spawner,monstertype):
	var astar:AStarGrid2D=_get_astar_grid(map,monstertype)
	var path=astar.get_id_path(spawner.map_position,targets[0].map_position)
	var global_path=[]
	for pos in path:
		global_path.append(map.map_to_local(pos))
	return global_path
	pass;	
#
static func _get_astar_grid(map:TileMap,monstertype:Stats.Monstertype)-> AStarGrid2D:
	var movable_cells=_get_movable_cells_per_monster_type(map,monstertype)
	var map_square=_get_map_square(map)
	var astar_grid=AStarGrid2D.new()
	astar_grid.region=map_square
	astar_grid.diagonal_mode=1
	astar_grid.fill_solid_region(map_square,false)
	#astar_grid.cell_size=Stats.block_size
	for movable in movable_cells:
		astar_grid.set_point_solid(movable,true)
	astar_grid.update()
	return astar_grid
	pass;
#returns the smallest and largest point of a map as a rect2i 	
static func _get_map_square(map):
	var smallest=Vector2(0,0)
	var biggest=Vector2(64,64)
	return Rect2i(smallest.x,smallest.y,biggest.x,biggest.y)
	pass;	
#returns an array of cells on which the given monster type can not move.
static func _get_movable_cells_per_monster_type(map: TileMap, monstertype: Stats.Monstertype)->PackedVector2Array:
		var cells: PackedVector2Array = []
		match(monstertype):
			Monster.MonsterMovingType.GROUND:
				for pos in map.get_used_cells(GameboardConstants.GROUND_LAYER):
					if GameboardConstants.get_tile_type(map, GameboardConstants.GROUND_LAYER, pos) != GameboardConstants.TileType.GROUND: #It is not a ground, ignore
						continue;
					if map.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos) == -1: #Block layer is free
						cells.append(pos)
				return cells
			Monster.MonsterMovingType.AIR:
				for y in range(0, Stats.LEVEL_EDITOR_HEIGHT): #Just put every possible tile in the array
					for x in range(0, Stats.LEVEL_EDITOR_WIDTH):
						cells.append(Vector2(x, y))
		
		return cells
		
func _draw():
	targets=state.targets
	var path = get_paths(targets,state.board,self,Stats.Monstertype.REGULAR)
	if path.size() == 0:
		return
	#lightened makes the line glow. for some reason this makes aqua and red the exact other color. i have no clue	
	var color = Color.RED if can_reach_target() else Color.AQUA
	color=color.lightened(8)
	for i in range(1, path.size()):
		draw_line(Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y),
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
