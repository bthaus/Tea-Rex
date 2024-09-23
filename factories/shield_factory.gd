extends Node3D
class_name ShieldFactory
static var instance=load("res://factories/shield_factory.tscn").instantiate()
enum ShieldType{energy}

static func get_shield_texture(type:ShieldType,level:int):
	set_singleton()
	var searchstring=ShieldType.keys()[type]+"_"+str(level)
	var sprite=Sprite2D.new()
	sprite.material=load('res://shaders/dissolve.tres')
	var node=instance.get_node(searchstring) as SubViewport
	sprite.texture=node.get_texture()
	return sprite;
static func set_singleton():
	if util.valid(instance) and instance.get_parent()!=null:
		return
	if !util.valid(instance):
		instance=load("res://factories/shield_factory.tscn").instantiate()
	GameState.gameState.add_child(instance)	
			
	pass;
