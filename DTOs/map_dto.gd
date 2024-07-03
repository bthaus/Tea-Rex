extends BaseDTO
class_name MapDTO

var entities:Array[BaseDTO]
var waves: WavesDTO
var map_name:String=""
var battle_slots:BattleSlotDTO;

func _init(entities: Array[BaseDTO]=[], waves: WavesDTO = WavesDTO.new(),mapname=""):
	self.entities = entities
	self.waves = waves
	self.map_name=mapname

func restore(dest,acc="",dir="maps"):
	return super.restore("map_"+dest,"",dir+"/"+dest)
		
func save(dest,acc="",dir="maps"):
	MapNameDTO.add_map_name(dest)
	return super.save("map_"+dest,"",dir+"/"+dest)
		
