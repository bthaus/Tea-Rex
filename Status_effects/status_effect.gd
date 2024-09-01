extends GameObjectCounted
class_name StatusEffect

var lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME
var time_slice_duration=1
var default_lifetime
var affected:GameObject2D
var associate
var strength:float=1
var to_remove=false;
var time_slice_time=0
var effectiveness=1

enum Name{BURNING,FROZEN,FREEZING,POISONED,OVERCHARGED,
FROZEN_TOWER,NONE,HIDDEN,DAMAGE,COOLDOWN,
RANGE,CAMOUFLAGE,STUN_TOWER,SPEEDBUFF,TIED}
var type:
	get:
		return get_name()
#needs to be overridden		
func get_name():
	return Name.NONE	
func _init(str=1,associate=null,lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME):
	self.lifetime=lifetime*1000
	self.default_lifetime=lifetime*1000
	self.strength=str
	self.associate=associate
	
	
	
func register(affected:GameObject2D):
	if affected is Monster:
		affected=affected.core
	if !util.valid(affected):return
	
	self.affected=affected
	self.effectiveness=affected.get_status_effect_effectiveness(get_name())
	register_container(affected,type)
	
	last_tick_time=Time.get_ticks_msec()
	affected.status_effects[type].add_status_effect(self)
	affected.status_effect_registered(self)
	pass;
func register_container(object,t):
	if !object.status_effects.has(t):object.status_effects[t]=get_container()	
	pass
func refresh():
	lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME*1000-1
	pass;	
var last_tick_time=0	


func on_tick(delta):
	#seperate custom deltatime for lifetime calculation, and regular delta for damage calculation
	var deltatime=Time.get_ticks_msec()-last_tick_time
	last_tick_time=Time.get_ticks_msec()
	lifetime-=deltatime
	time_slice_time+=delta
	if lifetime<0:
		to_remove=true
	elif time_slice_time>time_slice_duration:
		time_slice_time-=time_slice_duration
		apply_effect(delta)
	pass;
func on_initial_application():
	
	pass;
func on_removal():
	
	pass;		
func apply_effect(delta):
	pass;	
func get_str():
	return effectiveness
	pass;	
func get_container()->status_effect_container:
	return status_effect_container.new(affected)
func remove():
	affected.status_effects[type].remove_status_effect(self,0.001)
	pass;	

class status_effect_container:
	var status_effects=[]
	var immunity_stacks=0
	var strongest_status_effect:StatusEffect:
		set(val):
			if strongest_status_effect!=val:
				if strongest_status_effect!=null:strongest_status_effect.on_removal()
				strongest_status_effect=val
				if util.valid(strongest_status_effect):strongest_status_effect.on_initial_application()
	var visual
	var affected
	func _init(affected):
		self.affected=affected
	func remove():
		status_effects.clear()
		strongest_status_effect=null
		remove_visual()
		pass;	
	func get_strongest_status_effect()->StatusEffect:
		return strongest_status_effect
	
	func trigger(delta):
		if strongest_status_effect==null:return
		
		strongest_status_effect.on_tick(delta)
		if strongest_status_effect.to_remove:
			remove_status_effect(strongest_status_effect,delta)
			
		pass;
	func add_visual():
		var label=Label.new()
		label.z_index=100
		label.text=get_strongest_status_effect().get_name()
		get_strongest_status_effect().affected.add_child(label)
		label.position+=Vector2(randf_range(10,32),randf_range(10,32))
		visual=label
		pass;
	func remove_visual():
		if !util.valid(visual):return
		visual.queue_free()
		pass;
	func add_immunity_stack():
		immunity_stacks+=1
		if !status_effects.is_empty():
			status_effects.clear()
			remove_status_effect(strongest_status_effect,1);
			immunity_stacks-=1
		pass;			
	func add_status_effect(d:StatusEffect):
		if immunity_stacks>0:
			immunity_stacks-=1
			return
		if strongest_status_effect!=null and strongest_status_effect.get_str()==d.get_str():
			strongest_status_effect.refresh()
			return
		
		status_effects.push_back(d)
		compute_strongest_status_effect()
		if status_effects.is_empty():
			add_visual()
		
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
			if status_effect.get_str()>strongest.get_str():
				strongest=status_effect
		strongest_status_effect=strongest		
		pass;	
	
