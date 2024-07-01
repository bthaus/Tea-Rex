extends BaseDTO
class_name TurretDTO

var color: Stats.TurretColor
var level: int
var extension: Stats.TurretExtension
var x: int
var y: int

func get_object():
	return Turret.create(self.color, self.level, self.extension)
