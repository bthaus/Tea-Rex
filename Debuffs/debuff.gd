extends GameObjectCounted
class_name Debuff

var lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME
var default_lifetime
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
	self.default_lifetime=lifetime*1000
	self.strength=str
	
func register(affected:GameObject2D):
	if !affected.debuffs.has(type):affected.debuffs[type]=get_container()
	self.affected=affected
	last_tick_time=Time.get_ticks_msec()
	affected.debuffs[type].add_debuff(self)
	pass;
	
func refresh():
	lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME*1000-1
	pass;	
var last_tick_time=0	
func on_tick(delta):
	#seperate custom deltatime for lifetime calculation, and regular delta for damage calculation
	var deltatime=Time.get_ticks_msec()-last_tick_time
	last_tick_time=Time.get_ticks_msec()
	lifetime-=deltatime
	if lifetime<0:
		to_remove=true
	else:
		apply_effect(delta)
	pass;
func on_initial_application():
	
	pass;
func on_removal():
	
	pass;		
func apply_effect(delta):
	pass;	
	
func get_container()->debuff_container:
	return debuff_container.new(affected)
	

class debuff_container:
	var debuffs=[]
	var strongest_debuff:Debuff:
		set(val):
			
			if strongest_debuff!=val:
				strongest_debuff=val
				if val!=null:val.on_removal()
				strongest_debuff.on_initial_application()
	var visual
	var affected
	func _init(affected):
		self.affected=affected
		
	func get_strongest_debuff()->Debuff:
		return strongest_debuff
	
	func trigger(delta):
		if strongest_debuff==null:return
		
		strongest_debuff.on_tick(delta)
		if strongest_debuff.to_remove:
			remove_debuff(strongest_debuff,delta)
			
		pass;
	func add_visual():
		
		pass;
	func remove_visual():
		
		pass;		
	func add_debuff(d:Debuff):
		if debuffs.is_empty:
			add_visual()	
		if strongest_debuff!=null and strongest_debuff.strength==d.strength:
			strongest_debuff.refresh()
			return
		
		debuffs.push_back(d)
		compute_strongest_debuff()
		
	func remove_debuff(d:Debuff,delta):
		debuffs.erase(d)
		if debuffs.is_empty():
			remove_visual()
		compute_strongest_debuff()
		trigger(delta)
				
	func compute_strongest_debuff():
		if debuffs.is_empty(): strongest_debuff=null;return
		var strongest=debuffs[0]
		for debuff:Debuff in debuffs:
			if debuff.strength>strongest.strength:
				strongest=debuff
		strongest_debuff=strongest		
		pass;	
	
