extends BaseDTO
class_name MonsterWaveDTO

var spawner_id
var monster_id: int #TODO: should probably be an enum value MonsterType
var count: int

func _init(spawner_id: int = -1, monster_id: int = -1, count: int = -1):
	self.spawner_id = spawner_id
	self.monster_id = monster_id
	self.count = count
