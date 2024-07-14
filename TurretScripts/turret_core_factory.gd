extends Node2D
class_name TurretCoreFactory
static var instance=null;
@export var base_speed:float=750
@export var base_damage:float=5
@export var base_range:int=1
@export var base_cooldown:float=1.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getBase(color:Stats.TurretColor,extension:Stats.TurretExtension)->TurretCore:
	var searchstring=Stats.getStringFromEnum(color)+Stats.getStringFromEnumExtension(extension)+"_base"
	var base=get_node(searchstring).duplicate() as TurretCore
	base.type=color
	base.extension=extension
	base.visible=true
	base.damage=base.damage*base_damage
	base.speed=base.speed*base_speed
	base.turretRange=base.turretRange*base_range
	base.cooldown=base.cooldown*base_cooldown
	return base
static func get_instance()-> TurretCoreFactory:
	if instance==null:
		instance=load("res://TurretScripts/turret_core_factory.tscn").instantiate() as TurretCoreFactory
	return instance
	pass;	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
