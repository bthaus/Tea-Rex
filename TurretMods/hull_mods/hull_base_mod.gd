extends TurretBaseMod
class_name HullBaseMod

var base_reload_time=5
var shield
var reload_tween
func get_timeout():
	return base_reload_time/level
func get_type():
	return FreezeTowerDebuff
func get_max_stacks():
	return level	
func hit():
	set_shader_dissolve(get_interpolated_value(associate.get_immunity_stacks(get_type())))
	refresh_tween()
	pass;	
func set_shader_dissolve(val:float):
	if !util.valid(shield):return
	shield.material.set_shader_parameter("dissolve_value",val)
	pass;	
func initialise(turret:TurretCore):
	super(turret)
	if not associate.placed:return
	
	var shield=ShieldFactory.get_shield_texture(ShieldFactory.ShieldType.energy,level)
	self.shield=shield
	turret.add_child(shield)
	
	
	set_shader_dissolve(0)
	refresh_tween()
	
	pass;	

func add_immunity_stack():
	if !util.valid(associate):return
	print("added")
	var current_stacks=associate.get_immunity_stacks(get_type())
	if current_stacks==get_max_stacks():return
	var shine=GameState.gameState.create_tween()
	shine.tween_property(shield,"modulate",Color(2,2,2,1),0.2)
	shine.tween_property(shield,"modulate",shield.modulate,0.2)
	associate.add_immunity_stack(get_type())
	refresh_tween()	
	
	pass;
func refresh_tween():
	var current_stacks=associate.get_immunity_stacks(get_type()) as float
	if reload_tween!=null:
		reload_tween.kill()
	reload_tween=GameState.gameState.create_tween()
	reload_tween.finished.connect(add_immunity_stack)
	var interpol=get_interpolated_value(current_stacks+1) as float
	print(interpol)
	print("inbetween tween val")
	var current=shield.material.get_shader_parameter("dissolve_value")
	reload_tween.tween_method(set_shader_dissolve,current,interpol,get_timeout())
	pass;	
func get_interpolated_value(stack):
	var max_stacks=get_max_stacks()
	return remap(stack,0,max_stacks,0,1)
	pass;	
func remove():
	util.erase(shield)
	super()
	pass;
func on_level_up(lvl):
	super(lvl)
	if !util.valid(associate):return
	util.erase(shield)
	var shield=ShieldFactory.get_shield_texture(ShieldFactory.ShieldType.energy,lvl)
	self.shield=shield
	associate.add_child(shield)
	set_shader_dissolve(0)
	refresh_tween()
	pass;	
