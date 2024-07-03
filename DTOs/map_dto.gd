extends BaseDTO
class_name MapDTO

var entities:Array[BaseDTO]
var waves: WavesDTO
var map_name:String=""
var battle_slots:BattleSlotDTO;

func _init(entities: Array[BaseDTO]=[], waves: WavesDTO = WavesDTO.new()):
	self.entities = entities
	self.waves = waves

func restore(dest,acc="",dir="maps"):
	return super.restore("map_"+dest,"",dir+"/"+dest)
		
func save(dest,acc,dir):
	MapNameDTO.add_map_name(map_name)
	return super.save("map_"+dest,"",dir+"/"+dest)
		
