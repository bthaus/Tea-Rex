extends Node2D
class_name GameObject2D

var status_effects={}
## This object is not affected by these status effects. Immunities do not carry over -> FREEZING != FROZEN
@export var immunities:Array[StatusEffect.Name]=[]
## This description is shown in the pop-up that appears on hover.
@export var description:String
## node name is taken by default, is used for the pop-up that appears on hover 
@export var name_title:String=""


#@export var resistances:Array[Resistance]
func apply_status_effects(delta):
	for d in status_effects:
		status_effects[d].trigger(delta)
	pass;
func get_status_effect_effectiveness(name:StatusEffect.Name):
	var effect=1
	if immunities.has(name):
		effect=0
	#for res in resistances:
		#if res.resistance==name:
			#effect+=res.effect
	return effect	
func remove_status_effect(name):
	if status_effects.has(name):
		status_effects[name].remove()
	pass;				
func has_effect(name:StatusEffect.Name):
	if status_effects.has(name):
		if status_effects[name].get_strongest_status_effect()!=null:
			return true
	return false;		
	pass;
func status_effect_registered(effect:StatusEffect):
	pass;	
func add_immunity_stack(status_effect):
	var instance=status_effect.new()
	instance.register_container(self,instance.type)
	status_effects[instance.type].add_immunity_stack()
	pass;
func get_immunity_stacks(status_effect):
	var instance=status_effect.new()
	instance.register_container(self,instance.type)
	return status_effects[instance.type].immunity_stacks
			
func get_global():
	return global_position
	pass;
func get_reference():
	return GameState.gameState.collisionReference.getMapPositionNormalised(get_global())
	pass;	
func get_map():
	return GameState.board.local_to_map(get_global())
	pass;	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_hover(mouse_position):
	issue_popup(mouse_position)
	pass;
func issue_popup(mouse_position):
	var content= Popups.PopupContent.new()
	add_title(content)
	add_description(content)
	add_image(content)
	show_popup(content,mouse_position)
	pass;
func show_popup(c,mouse_position):
	Popups.show_popup_at(get_global(),c)
	pass;	
func add_title(c):
	if name_title=="":
		c.append_title(name)
	else:
		c.append_title(name_title)	
	pass;		
func add_image(c):
	pass;	
func add_description(c):
	c.append_description(description)
	pass;	
func on_unhover():
	
	pass;	
