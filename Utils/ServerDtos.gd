extends Node
class_name ServerDTOs

static func get_comment_dto(comment:String,user_name:String,map_name:String):
	return {
		"comment":comment,
		"user_name":user_name,
		"map_name":map_name
	}
static func get_map_dto(map_dto:MapDTO,user_name):
	map_dto.reduce()
	return {
		"name":map_dto.map_name,
		"reduced_entities":map_dto._reduced_entities,
		"reduced_shapes":map_dto._reduced_shapes,
		"reduced_waves":map_dto._reduced_waves,
		"user_name":user_name
	}
	
		

