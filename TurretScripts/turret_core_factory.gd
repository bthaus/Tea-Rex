extends Node2D
class_name TurretCoreFactory
static var instance=null;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getBase(color:Stats.TurretColor,extension:Stats.TurretExtension)->TurretCore:
	var searchstring=Stats.getStringFromEnum(color)+Stats.getStringFromEnumExtension(extension)+"_base"
	var base=get_node(searchstring).duplicate() as TurretCore
	base.type=color
	base.extension=extension
	base.visible=true
	return base
static func get_instance()-> TurretCoreFactory:
	if instance==null:
		instance=load("res://TurretScripts/turret_core_factory.tscn").instantiate() as TurretCoreFactory
	return instance
	pass;	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
