extends BaseDTO
class_name TreasureLookUpDTO
var treasures:Dictionary

func save(a=1,b=1,c=1):
	super("treasure_lookup","","treasures")
	pass;
func restore(a=1,b=1,c=1):
	super("treasure_lookup","","treasures")

static func add_treasure(id,item):
	
	pass;
static func get_dto()->TreasureLookUpDTO:
	var dto=TreasureLookUpDTO.new()
	dto.restore()
	return dto
