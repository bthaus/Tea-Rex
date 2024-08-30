extends Node2D
class_name TurretCoreFactory
static var instance=load("res://TurretScripts/turret_core_factory.tscn").instantiate() as TurretCoreFactory
static var mod_containers={}
@export var base_speed:float=750
@export var base_damage:float=5
@export var base_range:int=1
@export var base_cooldown:float=1.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func getBase(color:Turret.Hue,extension:Turret.Extension)->TurretCore:
	
	var searchstring=util.getStringFromEnum(color)+util.getStringFromEnumExtension(extension)+"_base"
	var base=instance.get_node(searchstring).duplicate() as TurretCore
	add_mods_to_core(base)
	base.type=color
	base.extension=extension
	base.visible=true
	base.damage=base.damage*instance.base_damage
	base.speed=base.speed*instance.base_speed
	base.turretRange=base.turretRange*instance.base_range
	base.cooldown=base.cooldown*instance.base_cooldown
	return base
static func get_mods_from_color(color):
	for cont:TurretModContainerDTO in mod_containers:
		if cont.color==color:
			return cont.turret_mods
	pass;	
static func register_mod_containers(dots):
	for container:TurretModContainerDTO in dots:
		mod_containers[container.color]=container.turret_mods
	pass;
static func add_mods_to_core(core:TurretCore):
	if mod_containers.is_empty():return
	for item:ItemBlockDTO in mod_containers[core.type]:
		var mod=util.copy_object_shallow(item.turret_mod)
		core.turret_mods.push_back(mod)
		
	pass;		
static func get_instance()-> TurretCoreFactory:
	if instance==null:
		instance=load("res://TurretScripts/turret_core_factory.tscn").instantiate() as TurretCoreFactory
	return instance
	pass;
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
