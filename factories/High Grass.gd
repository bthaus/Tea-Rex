extends BaseEntity
class_name HighGrassEntity
@export var dodge_chance:int=30
var effects={}
func trigger_minion(m:Monster):
	if weight_excludes.has(m.moving_type):return 
	var buff=CamouflageBuff.new(dodge_chance)
	buff.register(m)
	effects[m]=buff
	pass;
func on_cell_left(m:Monster):
	if !effects.has(m):return
	effects[m].remove()
	pass;	
	
