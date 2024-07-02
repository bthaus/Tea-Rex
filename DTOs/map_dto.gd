extends BaseDTO
class_name MapDTO

var entities:Array[BaseDTO]

func _init(entities: Array[BaseDTO]=[]):
	self.entities = entities
