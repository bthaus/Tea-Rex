extends BaseDTO
class_name TreasureDTO
var treasure
var id

static func add_treasure_to_map(map_name,treasure):
	var map=MapDTO.new()
	map.restore(map_name)
	
	var treasure_dto=TreasureDTO.new()
	treasure_dto.id=map_name
	treasure_dto.treasure=treasure
	
	if map.treasure_ids.has(map_name):
		map.treasures.clear()
		map.treasures.append(treasure_dto)
		map.save(map_name)
	pass;
