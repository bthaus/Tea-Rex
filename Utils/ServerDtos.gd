extends Node
class_name ServerDTOs

static func get_comment_dto(comment:String,user_id:int,map_id:int):
	return {
		"comment":comment,
		"user_id":user_id,
		"map_id":map_id
	}
static func get_map_dto(map_dto:MapDTO,user_id):
	map_dto.reduce()
	return {
		"name":map_dto.map_name,
		"reduced_entities":map_dto._reduced_entities,
		"reduced_shapes":map_dto._reduced_shapes,
		"reduced_waves":map_dto._reduced_waves,
		"user_id":user_id
		
	}
		

