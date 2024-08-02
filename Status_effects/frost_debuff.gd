extends StatusEffect
class_name FrostDebuff
#how much slow can be applied in total
var max_slow
var change=0


func _init(lifetime,associate,str,max):
	super(str,associate,lifetime)
	self.max_slow=max
	
	pass;
func get_name():
	return Name.FREEZING
func on_initial_application():
	affected=affected as MonsterCore
	change=affected.speed
	var effect=max_slow*get_str()
	affected.speed-=effect
	change-=affected.speed
	super()
	pass;
func on_removal():
	affected=affected as MonsterCore
	affected.speed+=change
	super()
	pass;
