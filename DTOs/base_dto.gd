extends GameObjectCounted
class_name BaseDTO
var __destination=""
var __account=""
var __directory=""


func save(destination,account,directory):

	var json=get_json()
	return GameSaver.save(json,destination,account,directory)!=-1 
func delete():
	return GameSaver.delete(__destination,__directory,__account);
	pass;	
func get_json():
	var props=get_script().get_script_property_list() as Array
	var values=[]
	#cleanup of class descriptors
	values.append(props.pop_front()["hint_string"])
	var removal_arr=[]
	for p in props:
		if p["name"].contains(".gd"): removal_arr.append(p)
		if p["name"].contains("__"): removal_arr.append(p)
	for p in removal_arr:
		props.erase(p)
	for p in props:
			var val=get(p["name"])
			val=_get_if_is_2D_array_of_dtos(val)	
			val=_get_if_is_array_of_dtos(val)
			val=_get_if_is_dto(val)
			val=_get_if_is_obj_arr(val)
			val=_get_if_is_obj(val)
			var d={p["name"]:val}
			values.append(d)
	var json=JSON.stringify(values," ")	
	return json
static func get_json_from_object(object):
	var props=object.get_script().get_script_property_list() as Array
	var values=[]
	#cleanup of class descriptors
	values.append(props.pop_front()["hint_string"])
	var removal_arr=[]
	for p in props:
		if p["name"].contains(".gd"): removal_arr.append(p)
		
	for p in removal_arr:
		props.erase(p)
	for p in props:
			var val=object.get(p["name"])
			val=_get_if_is_2D_array_of_dtos(val)	
			val=_get_if_is_array_of_dtos(val)
			val=_get_if_is_dto(val)
			
			var d={p["name"]:val}
			values.append(d)
	var json=JSON.stringify(values," ")	
	return json	
func _init():
	pass;	
static func _get_if_is_array_of_dtos(val):
	if val is Array and !val.is_empty() and val[0] is BaseDTO:
				var arr= val
				val=[] as Array
				for i in arr:
					val.append(i.get_json())
	return val					
static func _get_if_is_obj_arr(val):
	if val is Array:
		var arr=val
		val=[] as Array
		for o in arr:
			var temp=_get_if_is_obj(o);
			val.append(temp)
	return val			
	pass;

static func _get_if_is_obj(val):
	if val is Object:
		if not val.has_method("get_script"):return val
		var s=val.get_script().get_script_property_list().pop_front()
		val=s["hint_string"]
		print("object stringified")
	return val	
	pass;
	
static func _get_if_is_2D_array_of_dtos(val):
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

static func _get_if_is_dto(val):
	if val is BaseDTO:
		val=val.get_json()
	return val
	pass;		
func load_json(destination,account,directory):
	var json=GameSaver.loadfile(destination,account,directory)
	if json=="":
		return null;
	return json
	
static func get_dto_from_json(json):
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
		elif val is Array and !val.is_empty() and val[0] is String and val[0].contains(".gd"):
			var arrv=val;
			val = []
			for i in arrv:
				var t=load(i).new()
				val.append(t)			
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
	self.__destination=destination
	self.__account=account
	self.__directory=directory
	return true;
	
func get_object():
	
	return self;
	
