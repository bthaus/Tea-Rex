extends TurretBaseMod
class_name ProductionBaseMod
var base_build_time=5
var timer=Timer.new()
var cells=[]
var cache=[]
func get_timeout():
	return base_build_time
	
func initialise(turret:TurretCore):
	super(turret)
	timer.wait_time=get_timeout()
	turret.add_child(timer)
	timer.start(get_timeout())
	timer.timeout.connect(try_build_item)
	GameState.collisionReference.getNeighbours(associate.get_global(),cells)
	
	pass;	
func try_build_item():
	for cell in cells:
		var qualifies=true
		if GameState.collisionReference.get_turret_from_map(cell)!=null:continue
		if GameState.collisionReference.is_buildable_map(cell):
			for entity in GameState.collisionReference.get_entities_from_map(cell):
				if entity is ModProduce:
					qualifies=false;
					break;
		else:continue
		if qualifies:
			var produce=get_produce()	
			produce.map_position=cell	
			produce.place_on_board(GameState.board)	
			break;
	timer.start(get_timeout())		
	pass;	
func get_produce()->ModProduce:
	if cache.is_empty():
		var instance = instantiate_produce()
		instance.associate=self
		return instance
	else:
		return cache.pop_back()	
		
func instantiate_produce():
	return ModProduce.new()		
	
