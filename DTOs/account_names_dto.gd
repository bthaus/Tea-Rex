extends BaseDTO
class_name AccountNamesDTO

var names=[]

func save(a=1,b=1,c=1):
	super.save("account_names","","acc_infos")
	pass;
func restore(a=1,b=1,c=1):
	super.restore("account_names","","acc_infos")
	if names!=null:return
	#if no account_names dto is present, create one
	print("no accountdto found, creating new one")
	names=[]
	save()
	
		
	pass;	
static func add_account_name(name:String):
	var dto=AccountNamesDTO.new()
	dto.restore()
	if dto.names.find(name)==-1:
		dto.names.append(name)
		dto.save()
		return true;
	else: return false;	
	pass;
static func exists_account_name(name:String):
	var dto=AccountNamesDTO.new()
	dto.restore()
	return dto.names.find(name)!=-1
static func remove_account(name:String):
	var dto=AccountNamesDTO.new()
	dto.restore()
	dto.names.erase(name)
	pass;	

static func get_names():
	var dto=AccountNamesDTO.new()
	dto.restore()
	return dto.names
	
