extends TurretBaseMod
class_name ProductionBaseMod
var base_build_time=5
var timer=Timer.new()
var cells:Array[CollisionReference.Holder]
var cache=[]
func get_timeout():
	return base_build_time
	
func on_turret_build(turret:TurretCore):
	timer.wait_time=get_timeout()
	turret.add_child(timer)
	timer.start(get_timeout())
	timer.timeout.connect(try_build_item)
	cells=GameState.collisionReference.get_cells_around_pos(associate.get_global(),1,false)
	
	pass;	
func try_build_item():
	for cell:CollisionReference.Holder in cells:
		var qualifies=true
		if cell.turret!=null:continue
		if GameState.collisionReference.is_buildable_map(cell.pos):
			for entity in cell.entities:
				if entity is ModProduce:
					qualifies=false;
					break;
		else:continue
		if qualifies:
			var produce=get_produce()	
			produce.map_position=cell.pos	
			produce.place_on_board(GameState.board)	
	timer.start(get_timeout())		
	pass;	
func get_produce()->ModProduce:
	if cache.is_empty():
		var instance = instantiate_produce()
		instance.associate=self
		return instance
	else:
		return cache.pop_back()	
		
func instantiate_produce()->ModProduce:
	return ModProduce.new()		
	
