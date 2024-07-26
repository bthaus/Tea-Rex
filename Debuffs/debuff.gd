extends GameObjectCounted
class_name Debuff

var lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME
var affected:GameObject2D
var strength:float
var to_remove=false;
var type:
	get:
		return get_name()
#needs to be overridden		
func get_name():
	return "default"	
func _init(str,lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME):
	self.lifetime=lifetime*1000
	self.strength=str
	
func register(affected:GameObject2D):
	if !affected.debuffs.has(type):affected.debuffs[type]=[]
	affected.debuffs[type].push_back(self)
	affected.debuffs[type].sort_custom(order_by_strenght)
	self.affected=affected
	last_tick_time=Time.get_ticks_msec()
	pass;
	
func order_by_strenght(a,b):
	return a.strength>b.strength
	pass;	

func refresh():
	lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME
	pass;	
var last_tick_time=0	
func on_tick():
	var delta=Time.get_ticks_msec()-last_tick_time
	last_tick_time=Time.get_ticks_msec()
	lifetime-=delta
	if lifetime<0:
		to_remove=true
	else:
		apply_effect(delta)
	pass;
func apply_effect(delta):
	
	pass;	
func remove():
	affected.debuffs[type].erase(self)
	affected.debuffs[type].sort_custom(order_by_strenght)
	pass;	

class debuff_container:
	var debuffs=[]
	var strongest_debuff:Debuff
	var visual
	
	func compute_strongest_buff():
		var strongest=0
		for debuff:Debuff in debuffs:
			if debuff.strength>strongest.strength:
				strongest=debuff
		strongest_debuff=strongest		
		pass;	
	
