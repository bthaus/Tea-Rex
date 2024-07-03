extends EntityDTO
class_name TurretDTO

var color: Stats.TurretColor
var level: int
var extension: Stats.TurretExtension

func _init(tile_id: int = -1, layer: int = -1, x: int = -1, y: int = -1):
	super(tile_id, layer, x, y)

func get_object():
	return Turret.create(color, level, extension)
