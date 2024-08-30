extends StatusEffect
class_name SpeedBuff
var speed
var change=0
func get_name():
	return Name.SPEEDBUFF
	pass;

func _init(speed_factor,lifetime):
	speed=speed_factor
	super(1,null,lifetime)
	pass;

func on_initial_application():
	affected=affected as MonsterCore
	change=affected.speed
	var effect=speed*get_str()
	affected.speed+=effect
	change-=affected.speed
	super()
	pass;
func on_removal():
	affected=affected as MonsterCore
	affected.speed+=change
	super()
	pass;
