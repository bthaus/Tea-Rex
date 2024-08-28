extends BaseDTO
class_name MapDTO

var entities: Array[BaseDTO]
var waves
#TODO: change that to an actual number
var number_of_waves: int = 2
var map_name: String = ""
var battle_slots: BattleSlotDTO
var block_cycle: Array[BaseDTO]
var color_cycle: Array

func _init(entities: Array[BaseDTO] = [], waves = [], block_cycle: Array[BaseDTO] = [], color_cycle: Array = [], mapname = ""):
	self.entities = entities
	self.waves = waves
	self.block_cycle = block_cycle
	self.color_cycle = color_cycle
	self.map_name=mapname

func restore(dest,acc="",dir="maps"):
	return super.restore("map_"+dest,"",dir+"/"+dest)
		
func save(dest,acc="",dir="maps"):
	MapNameDTO.add_map_name(dest)
	return super.save("map_"+dest,"",dir+"/"+dest)
		
