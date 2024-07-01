extends RefCounted
class_name BaseDTO
var destination="defaultValue"
var account="noAcc"

func save():
	GameSaver.save(get_json(),destination,account) 
	pass
func get_json():
	var props=get_script().get_script_property_list() as Array
	var values=[]
	values.append(props.pop_front()["hint_string"])
	for p in props:
			var val=get(p["name"])
			var d={p["name"]:val}
			values.append(JSON.stringify(d))
	var json=JSON.stringify(values)	
	pass;
func _init(destination:String="defaultValue",account:String="noAcc",isSingleton:bool=false):
	self.destation=destination
	self.account=account
	if isSingleton:
		restore(destination,account)
		DTORegistry.registerDTO(self)
	pass;	
	
func load_json(destination,account):
	var json=GameSaver.loadfile(destination,account)
	if json=="":
		return null;
	return json
	
static func get_dto_from_json(json)->BaseDTO:
	var data=JSON.parse_string(json)as Array
	var obj=load(data.pop_front()).new()
	return _restore_fields(obj,data)

static func _restore_fields(obj,arr):
	for d in arr:
		var da=JSON.parse_string(d) as Dictionary
		var dakey=da.keys()[0]
		obj.set(dakey,da.get(dakey))
	pass;		
func restore(destination, account):
	var json=load_json(destination,account)
	if json==null: return;
	var data=JSON.parse_string(json)as Array
	data.pop_front()
	_restore_fields(self,data)
	
func get_object():
	
	return self;
	

