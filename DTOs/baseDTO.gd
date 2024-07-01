extends RefCounted
class_name BaseDTO
var destination="defaultValue"
var account="noAcc"
func save():
	var props=get_script().get_script_property_list() as Array
	var values=[]
	values.append(props.pop_front()["hint_string"])
	for p in props:
			var val=get(p["name"])
			var d={p["name"]:val}
			values.append(JSON.stringify(d))
	var json=JSON.stringify(values)		
	GameSaver.save(json,destination,account) 
	return json
	pass
static func restore(json):
	var data=JSON.parse_string(json)as Array
	var class_data=load(data.pop_front()).new()
	for d in data:
		var da=JSON.parse_string(d) as Dictionary
		var dakey=da.keys()[0]
		class_data.set(dakey,da.get(dakey))
	return class_data	
func getObject():
	
	return self;	
	

