extends Node3D
class_name ShieldFactory
static var instance=load("res://factories/shield_factory.tscn").instantiate()
static var dissolve_ressource=load('res://shaders/dissolve.tres')
enum ShieldType{energy}

static func get_shield_texture(type:ShieldType,level:int):
	set_singleton()
	var searchstring=ShieldType.keys()[type]+"_"+str(level)
	var sprite=ShieldSprite.new()
	sprite.material=dissolve_ressource.duplicate()
	#var shine=Sprite2D.new()
	#shine.material=load('res://shaders/shinematerial.tres').duplicate()
	#shine.texture=load("res://.godot/imported/empty.png-ca44899624833181660f8f3cd24b3803.ctex")
	#sprite.clip_children=CanvasItem.CLIP_CHILDREN_AND_DRAW
	#sprite.add_child(shine)
	
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
