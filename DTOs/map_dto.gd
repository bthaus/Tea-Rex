extends BaseDTO
class_name MapDTO

var entities:Array[BaseDTO]
var map_name:String=""


func _init(entities: Array[BaseDTO]=[]):
	self.entities = entities
	
func save(dest,acc,dir):
	MapNameDTO.add_map_name(map_name)
	return super.save(dest,acc,dir)
		
