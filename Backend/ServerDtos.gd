extends Node
class_name ServerDTOs

static func get_comment_dto(comment:String,user_id:int,map_id:int):
	return {
		"comment":comment,
		"user_id":user_id,
		"map_id":map_id
	}
static func get_map_dto(map_dto:MapDTO):
	return {
		"name":map_dto.map_name,
		"description":map_dto.description,
		
	}
		
