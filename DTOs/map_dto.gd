extends BaseDTO
class_name MapDTO

var entities:Array[BaseDTO]
var map_name:String=""
var battle_slots:BattleSlotDTO;

func _init(entities: Array[BaseDTO]=[]):
	self.entities = entities
func restore(dest,acc,dir):
	return super.restore("map_"+dest,"",dir+"/"+dest)
		
func save(dest,acc,dir):
	MapNameDTO.add_map_name(map_name)
	return super.save("map_"+dest,"",dir+"/"+dest)
		
