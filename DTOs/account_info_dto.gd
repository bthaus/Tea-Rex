extends BaseDTO
class_name AccountInfoDTO

var account_name:String
#TODO: check if typed array of subclass of BaseDTO works in restoration
var account_progress:Array[MapStatusDTO]=[]


func _init(name="-1"):
	account_name=name
	super()
	pass;

func save(name,acc="-1",dir="-1"):
	AccountNamesDTO.add_account_name(name)
	super.save(name,"","acc_infos/"+name)
	pass;

func restore(name,acc="-1",dir="-1"):
	super.restore(name,"","acc_infos/"+name)
	pass;
