extends Node
class_name ServerDTOs

static func get_list_level_dto(
	map_id: String,
	map_name: String,
	author: String,
	wave_lengths: Array[int], #Contains all allowed wave lengths so 1-5 -> [1, 2, 3, 4, 5]
	clear_rate_up_to: float, #Value between 0.0 and 1.0, 
	sort_by: String,
	page_number: int,
	page_size: int
	):
		return {
			"map_id": map_id,
			"map_name": map_name,
			"author": author,
			"wave_lengths": wave_lengths,
			"clear_rate_up_to": clear_rate_up_to,
			"sort_by": sort_by,
			"page_number": page_number,
			"page_size": page_size
			}

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
