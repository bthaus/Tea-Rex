extends Node
class_name Waves
@export var state:GameState
signal wave_done
var numMonstersActive=0;
@onready var nav: NavigationAgent2D = $NavigationAgent2D
# Called when the node enters the scene tree for the first time.
func _ready():
	nav.target_position = $Base.global_position
	nav.debug_enabled

	
func start(wavenumber:int):
	var amountmonsters=10+wavenumber*3;
	var map=state.gameBoard.get_child(0) as TileMap
	var cells=map.get_used_cells(0);
	amountmonsters=cells.size()-16*4+4
	Stats.enemy_base_HP=Stats.enemy_base_HP*1.1
	print(Stats.enemy_base_HP)
	numMonstersActive=amountmonsters;
	for n in range(0,amountmonsters):
		get_tree().create_timer(n*0.5).timeout.connect(spawnEnemy.bind(Stats.getiterativeColor(0),$Base))

		
	pass;
func spawnEnemy(c,t):
	var mo=Monster.create(c,t)
	mo.monster_died.connect(monsterDied)
	
	add_child(mo)

	pass;
func monsterDied():
	
	numMonstersActive=numMonstersActive-1;
	print(numMonstersActive)
	if numMonstersActive==0:
		wave_done.emit()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nav.get_next_path_position()
	getPath()
	
func getPath():
	var path = nav.is_target_reachable()
	
