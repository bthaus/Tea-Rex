extends Node2D
class_name Spawner
var state:GameState
signal wave_done

static var numMonstersActive=0;
var waveMonsters=[]
var minMonster=5
var maxMonster=100
var target:Node2D
var level;
@onready var nav: NavigationAgent2D = $NavigationAgent2D
# Called when the node enters the scene tree for the first time.
func _ready():
	nav.target_position = target.global_position

static func create(gameState:GameState,pos:Vector2,level:int=1)-> Spawner:
	var s=load("res://Spawner.tscn").instantiate() as Spawner;
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
	gameState.spawners.clear();
	gameState.spawners.append(s)
	return s;
		
func start(wavenumber:int):
	
	doBalancingLogic(wavenumber)
	doSpawnLogic(wavenumber)
		
	pass;
func doBalancingLogic(waveNumber:int):
	var amountmonsters=int(remap(waveNumber*3,0,50,minMonster,maxMonster))
	amountmonsters=clamp(amountmonsters,minMonster,maxMonster)
	numMonstersActive=numMonstersActive+amountmonsters
	print("im spawning "+str(amountmonsters)+" monsters")
	waveMonsters.clear()
	for n in range(amountmonsters):
		var strenght=clamp(waveNumber,1,global_position.y/100)
		waveMonsters.append(Monster.create(Stats.getiterativeColor(0),target,waveNumber))
	util.p("Im changing the stats of the minions and adding them to the array")
	
	pass;
func doSpawnLogic(waveNumber:int):
	var delay=1;
	for mo in waveMonsters:
		delay=delay+1;
		get_tree().create_timer(0.2*delay).timeout.connect(spawnEnemy.bind(mo))
	util.p("im taking minions from the array and spawn them in a sensible way")
	pass;
func spawnEnemy(mo:Monster):
	mo.monster_died.connect(monsterDied)
	mo.monster_died.connect(state.addExp)
	add_child(mo)

	pass;
func monsterDied(monster:Monster):
	
	numMonstersActive=numMonstersActive-1;
	print(numMonstersActive)
	if numMonstersActive<=0:
		state.startBuildPhase()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nav.get_next_path_position()
	queue_redraw()
	
func can_reach_target():
	return nav.is_target_reachable()
	
func _draw():
	var path = nav.get_current_navigation_path()
	if path.size() == 0:
		return
	var color = Color.WHITE if can_reach_target() else Color.RED
	for i in range(1, path.size()):
		draw_line(Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y),
		Vector2(path[i].x - global_position.x, path[i].y - global_position.y), color, 3, true)
