extends RefCounted
class_name DTORegistry
static var dtos:Array[BaseDTO]=[]

static func registerDTO(dto:BaseDTO):
	if dtos.find(dto)==-1:
		dtos.append(dto)
	pass;
static func saveDTOs():
	for dto in dtos:
		dto.save()
	pass;
