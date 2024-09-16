extends BaseDTO
class_name MapNameDTO
var names=[]

func save(a=1,b=1,c=1):
	super.save("map_names","","maps")
	pass;
func restore(a=1,b=1,c=1):
	if super.restore("map_names","","maps"):return
	save()
		
	pass;	
static func add_map_name(name:String):
	var dto=MapNameDTO.new()
	dto.restore()
	if dto.names.find(name)==-1:
		dto.names.append(name)
		dto.save()
		return true;
	else: return false;	
	pass;

static func exists_map_name(name:String):
	var dto=MapNameDTO.new()
	dto.restore()
	return dto.names.find(name)!=-1
	
static func remove_mapnname(name:String):
	var dto=MapNameDTO.new()
	dto.restore()
	dto.names.erase(name)
	dto.save()
	pass;	
