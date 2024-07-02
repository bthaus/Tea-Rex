extends RefCounted
class_name BaseDTO


func save(destination,account,directory):
	var json=get_json()
	return GameSaver.save(json,destination,account,directory)!=-1 
	
func get_json():
	var props=get_script().get_script_property_list() as Array
	var values=[]
	#cleanup of class descriptors
	values.append(props.pop_front()["hint_string"])
	if props.back()["name"]=="base_dto.gd":props.pop_back()
	
	for p in props:
			var val=get(p["name"])
			if val is Array[BaseDTO]:
				var arr= val
				val=[]
				for i in arr:
					val.append(i.get_json())
			var d={p["name"]:val}
			values.append(d)
	var json=JSON.stringify(values," ")	
	return json
	
func _init(destination:String="defaultValue",account:String="noAcc"):
	self.destation=destination
	self.account=account
	
	pass;	
	
func load_json(destination,account,directory):
	var json=GameSaver.loadfile(destination,account,directory)
	if json=="":
		return null;
	return json
	
static func get_dto_from_json(json)->BaseDTO:
	var data=JSON.parse_string(json)as Array
	var obj=load(data.pop_front()).new()
	_restore_fields(obj,data)
	return obj

static func _restore_fields(obj,arr):
	for d in arr:
		var da=d as Dictionary
		var dakey=da.keys()[0]
		var val=da.get(dakey)
		if val is Array:
			var temparr=val
			val=[] as Array[BaseDTO]
			for i in temparr:
				var idto=get_dto_from_json(i)
				val.append(idto)	
		obj.set(dakey,val)
	pass;		
func restore(destination,account,directory):
	var json=load_json(destination,account,directory)
	if json==null: return;
	var data=JSON.parse_string(json)as Array
	data.pop_front()
	_restore_fields(self,data)
	
	
func get_object():
	
	return self;
	

