extends Node2D
class_name ModVisualFactory

static var instance=load("res://TurretMods/mod_visual_factory.tscn").instantiate()


static  func get_visual(mod:TurretBaseMod)->ModVisual:
	
	return instance.get_node("template_visual").duplicate()
	
