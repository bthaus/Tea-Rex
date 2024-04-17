extends Node
class_name Waves

signal wave_done
var numMonstersActive=0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func start(wavenumber:int):
	var amountmonsters=13;
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
	if numMonstersActive==0:
		wave_done.emit()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
