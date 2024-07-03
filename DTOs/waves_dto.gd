extends BaseDTO
class_name WavesDTO

var waves #Should be an array of MonsterWaveDTO arrays, but Godot says no to nested typed collections.

func _init(waves = []):
	self.waves = waves
