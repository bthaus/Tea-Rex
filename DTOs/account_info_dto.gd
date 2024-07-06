extends BaseDTO
class_name AccountInfoDTO

var account_name:String
#TODO: check if typed array of subclass of BaseDTO works in restoration
var account_progress:Array[MapStatusDTO]=[]


func _init(name="-1"):
	account_name=name
	super()
	pass;

func save(name="-1",acc="-1",dir="-1"):
	if name=="-1" and account_name!=null:
		name=account_name
		
	AccountNamesDTO.add_account_name(name)
	super.save(name,"","acc_infos/"+name)
	pass;

func restore(name,acc="-1",dir="-1"):
	super.restore(name,"","acc_infos/"+name)
	pass;
#this method for sure returns the progress dto of a player. For sake of ease, if none is found, a progressdto is created
#this way we dont have to worry about creating progress dtos for all accounts everytime we create a new map	
func get_map_progress_dto_by_name(name)-> MapStatusDTO:
	for ms in account_progress:
		if ms.map_name==name:
			return ms
	var new_dto= MapStatusDTO.new(name)
	account_progress.append(new_dto)
	return new_dto	


