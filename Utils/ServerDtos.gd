extends Node
class_name ServerDTOs

static func get_comment_dto(comment:String,user_name:String,map_id:int):
	return {
		"comment":comment,
		"user_name":user_name,
		"map_id":map_id
	}
static func get_map_dto(map_dto:MapDTO,user_name):
	map_dto.reduce()
	return {
		"name":map_dto.map_name,
		"reduced_entities":map_dto._reduced_entities,
		"reduced_shapes":map_dto._reduced_shapes,
		"reduced_waves":map_dto._reduced_waves,
		"user_name":user_name,
		"slot_amount":map_dto.battle_slots.amount,
		"number_of_waves":map_dto.number_of_waves,
		"description":map_dto.description
		
		
		
	}

static func get_rating_dto(map_id:int,user_name:String,rating:int):
	return {
		"rating":rating,
		"user_name":user_name,
		"map_id":map_id
	}
static func get_account(user_name,password,email):
	var hash=hash_password(password)
	return {"user_name":user_name,
	"password":hash,
	"email":email
	}		
static func hash_password(password: String) -> String:
	var hash = HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(password.to_utf8_buffer())
	return hash.finish().hex_encode()		
