extends Node2D
class_name Spawner
@export var state:GameState
signal wave_done
static var numMonstersActive=0;
var waveMonsters=[]
var gamestate:GameState;
@onready var nav: NavigationAgent2D = $NavigationAgent2D
# Called when the node enters the scene tree for the first time.
func _ready():
	nav.target_position = $Base.global_position


func start(wavenumber:int):
	
	doBalancingLogic(wavenumber)
	doSpawnLogic(wavenumber)
		
	pass;
func doBalancingLogic(waveNumber:int):
	var amountmonsters=10+waveNumber*3;
	numMonstersActive=numMonstersActive+amountmonsters;
	for n in range(amountmonsters):
		waveMonsters.append(Monster.create(Stats.getiterativeColor(0),$Base))
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
		wave_done.emit()
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

	for i in range(1, path.size()):
		draw_line(Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y),
		Vector2(path[i].x - global_position.x, path[i].y - global_position.y), Color.WHITE, 3, true)
