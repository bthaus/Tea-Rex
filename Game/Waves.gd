extends GameObject2D
class_name Spawner
var state:GameState
signal wave_done

static var numMonstersActive=0;
var waveMonsters=[]
var minMonster=5
var maxMonster=Stats.max_enemies_per_spawner
var target:Node2D
var level;
var rnd = RandomNumberGenerator.new()
var numReachedSpawn:float=0;
var numDied:float=0;
var numSpawned:float=0;

@onready var nav: NavigationAgent2D = $NavigationAgent2D
# Called when the node enters the scene tree for the first time.
func _ready():
	nav.path_changed.connect(queue_redraw)
	state.start_build_phase.connect(func():
		if state.spawners.find(self)==-1:queue_free()
		)
	GameState.gameState.player_died.connect(func():
		for m in waveMonsters:
			if m != null:m.queue_free())
	nav.target_position = target.global_position

static func create(gameState:GameState,pos:Vector2,level:int=1)-> Spawner:
	var s=load("res://GameBoard/Spawner.tscn").instantiate() as Spawner;
	s.state=gameState;
	s.target=gameState.target
	s.level=level;
	gameState.add_child(s)
	
	s.global_position=pos
	
	return s
func serialise():
	return JSON.stringify({"x":position.x,"y":position.y,"lvl":level});
		
	
static func deserialise(json:String,gameState:GameState)->Spawner:
	var d=JSON.parse_string(json) as Dictionary
	var p=Vector2(d.get("x"),d.get("y"))
	var s=Spawner.create(gameState,p,d.get("lvl"))
	gameState.spawners.append(s)
	return s;
		
func start(wavenumber:int):
	
	if level>1:level=level-1
	doBalancingLogic(wavenumber)
	doSpawnLogic(wavenumber)
		
	pass;
func doBalancingLogic(waveNumber:int):
	var amountmonsters=int(remap(waveNumber+3,0,50,minMonster,maxMonster)/level)
	amountmonsters=clamp(amountmonsters,minMonster,maxMonster)
	numMonstersActive=numMonstersActive+amountmonsters
	numSpawned=numSpawned+amountmonsters;
	waveMonsters.clear()
	for n in range(amountmonsters):
		var strenght=clamp(waveNumber,1,global_position.y/100)/level
		waveMonsters.append(Monster.create(Stats.Monstertype.values().pick_random(),target,strenght
		))
	util.p("Im changing the stats of the minions and adding them to the array")
	
	pass;
func doSpawnLogic(waveNumber:int):
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
	mo.monster_died.connect(state.addExp)
	mo.reached_spawn.connect(monsterReachedSpawn)
	mo.global_position=global_position
	mo.path=nav.get_current_navigation_path()
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
	
func _draw():
	var path = nav.get_current_navigation_path()
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
	state.menu.showDescription(percentage+"% of minions spawned reached your base. ")
	pass # Replace with function body.


func _on_button_mouse_exited():
	state.menu.hideDescription()
	pass # Replace with function body.
