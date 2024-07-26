extends GameObjectCounted
class_name BaseDTO


func save(destination,account,directory):
	var json=get_json()
	return GameSaver.save(json,destination,account,directory)!=-1 
	
func get_json():
	var props=get_script().get_script_property_list() as Array
	var values=[]
	#cleanup of class descriptors
	values.append(props.pop_front()["hint_string"])
	var removal_arr=[]
	for p in props:
		if p["name"].contains(".gd"): removal_arr.append(p)
	for p in removal_arr:
		props.erase(p)
	for p in props:
			var val=get(p["name"])
			val=_get_if_is_2D_array_of_dtos(val)	
			val=_get_if_is_array_of_dtos(val)
			val=_get_if_is_dto(val)
			var d={p["name"]:val}
			values.append(d)
	var json=JSON.stringify(values," ")	
	return json
	
func _init():
	pass;	
func _get_if_is_array_of_dtos(val):
	if val is Array and !val.is_empty() and val[0] is BaseDTO:
				var arr= val
				val=[] as Array
				for i in arr:
					val.append(i.get_json())
	return val					

func _get_if_is_2D_array_of_dtos(val):
	if val is Array:
				if !val.is_empty() and val[0] is Array and !val[0].is_empty() and val[0][0] is BaseDTO:
					var arr= val
					val=[] 
					for a in arr:
						var innerarr=[] 
						for dto in a:
							var dtojson=dto.get_json()
							innerarr.push_back(dtojson)
						val.append(innerarr)
	return val

func _get_if_is_dto(val):
	if val is BaseDTO:
		val=val.get_json()
	return val
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
		
		if val is Array and !val.is_empty() and val[0] is Array :
			var outerarr=val;
			val=[]
			for innerarr in outerarr:
				var dtoarr=[] 
				for dto in innerarr:
					dtoarr.append(get_dto_from_json(dto))
				val.append(dtoarr)
				
		if val is Array and !val.is_empty() and val[0] is String and val[0].contains("dto.gd"):
			var temparr=val
			val=[] as Array[BaseDTO]
			for i in temparr:
				var idto=get_dto_from_json(i)
				val.append(idto)
					
		if val is String and val.contains("dto.gd"):
			val=get_dto_from_json(val)	
		elif val is String and val.contains(".gd"):
			val=load(val).new()	
		obj.set(dakey,val)
	pass;		
func restore(destination,account,directory):
	var json=load_json(destination,account,directory)
	if json==null: return false;
	var data=JSON.parse_string(json)
	data.pop_front()
	_restore_fields(self,data)
	return true;
	
func get_object():
	
	return self;
	

