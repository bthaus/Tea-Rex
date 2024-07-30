extends GameObjectCounted
class_name StatusEffect

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
	if !affected.status_effects.has(type):affected.status_effects[type]=get_container()
	self.affected=affected
	last_tick_time=Time.get_ticks_msec()
	affected.status_effects[type].add_status_effect(self)
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
	
func get_container()->status_effect_container:
	return status_effect_container.new(affected)
	

class status_effect_container:
	var status_effects=[]
	var strongest_status_effect:StatusEffect:
		set(val):
			
			if strongest_status_effect!=val:
				strongest_status_effect=val
				if val!=null:val.on_removal()
				strongest_status_effect.on_initial_application()
	var visual
	var affected
	func _init(affected):
		self.affected=affected
		
	func get_strongest_status_effect()->StatusEffect:
		return strongest_status_effect
	
	func trigger(delta):
		if strongest_status_effect==null:return
		
		strongest_status_effect.on_tick(delta)
		if strongest_status_effect.to_remove:
			remove_status_effect(strongest_status_effect,delta)
			
		pass;
	func add_visual():
		
		pass;
	func remove_visual():
		
		pass;		
	func add_status_effect(d:StatusEffect):
		if status_effects.is_empty:
			add_visual()	
		if strongest_status_effect!=null and strongest_status_effect.strength==d.strength:
			strongest_status_effect.refresh()
			return
		
		status_effects.push_back(d)
		compute_strongest_status_effect()
		
	func remove_status_effect(d:StatusEffect,delta):
		status_effects.erase(d)
		if status_effects.is_empty():
			remove_visual()
		compute_strongest_status_effect()
		trigger(delta)
				
	func compute_strongest_status_effect():
		if status_effects.is_empty(): strongest_status_effect=null;return
		var strongest=status_effects[0]
		for status_effect:StatusEffect in status_effects:
			if status_effect.strength>strongest.strength:
				strongest=status_effect
		strongest_status_effect=strongest		
		pass;	
	
