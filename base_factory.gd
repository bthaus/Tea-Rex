extends Node2D
class_name TurretCoreFactory

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getBase(color:Stats.TurretColor,extension:Stats.TurretExtension)->TurretCore:
	var searchstring=Stats.getStringFromEnum(color)+Stats.getStringFromEnumExtension(extension)+"_base"
	var base=get_node(searchstring).duplicate() as TurretCore
	base.visible=true
	return base
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
