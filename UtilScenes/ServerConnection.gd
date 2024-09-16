extends HTTPRequest
const server_base_route="https://rgba-latest.onrender.com/"
#const server_base_route="http://localhost:8080/"
var token=""
signal request_finished(result,response_code)
func _ready():
	request_completed.connect(_on_request_completed)
	
func _on_request_completed(result, response_code, headers, body):
	check_for_token(headers)
	var json = body.get_string_from_utf8()
	
	var data=JSON.parse_string(json) as Array
	var point=data[0] as Dictionary
	print(point["description"])
	
	request_finished.emit(data,response_code)
	print(json)

func check_for_token(headers):
	for s:String in headers:
		if s.contains("token"):
			token=s.substr(s.find("=")+1)+"hi"
			var dto=Global.get_account()
			dto._active_token=token
			dto.save()
	pass;
func register_user(username,password,email):
	var data=ServerDTOs.get_account(username,password,email)
	POST("register_acc",data)	
func get_headers():
	var tokencookie="token="+token
	return  ["Content-Type: application/json","Cookie: "+tokencookie]


func get_maps_from_user(username):
	GET("get_maps_from_user/"+username)
	
func send_map(map_dto:MapDTO):
	var id=Global.get_account().account_name
	var dto=ServerDTOs.get_map_dto(map_dto,id)
	POST("validated/add_map",dto)
	pass;	
func get_map(map_id:int):
	GET("get_map/"+str(map_id))
	pass;
func add_rating_to_map(rating:int,map_id:int,user_name:String):
	var dto=ServerDTOs.get_rating_dto(map_id,user_name,rating);
	POST("validated/add_rating_to_map",dto)
			
func send_comment(comment:String,map_id:int):
	var id=Global.get_account().account_name
	var dto=ServerDTOs.get_comment_dto(comment,id,map_id)
	POST("validated/add_comment",dto)
	pass;	
func get_comments(map_id:int):
	GET("get_comments_from_map/"+str(map_id))
	pass;	


func POST(route,data_dic):
	
	var json=JSON.stringify(data_dic)
	request(server_base_route+route, get_headers(), HTTPClient.METHOD_POST, json)
	pass;
func GET(route):
	request(server_base_route+route,get_headers())
	pass;	


#region Debuggin button connections

func _on_sen_pressed():
	send_comment("geile map",1)
	pass # Replace with function body.


func _on_get_pressed():
	get_comments(1)
	pass # Replace with function body.


func _on_map_pressed():
	var map=MapDTO.new()
	map.restore("sim_debug")
	#map.map_name+=str(randi())
	send_map(map)

	pass # Replace with function body.


func _on_button_pressed():
	get_map(1)
	pass # Replace with function body.

	
func _on_get_maps_from_user_pressed():
	get_maps_from_user("JohnDoe")
	pass # Replace with function body.


func _on_button_2_pressed():
	add_rating_to_map(5,1,"JohnDoe")
	pass # Replace with function body.




func _on_addacc_pressed():
	register_user(Global.get_account().account_name+str(randi_range(10,1111322)),"bodopw","bwuest@gmx.at"+str(randi_range(10,1111322)))
	pass # Replace with function body.


func _on_getmaps_pressed():
	GET("get_map_infos")
	pass # Replace with function body.

#endregion


func _on_delete_map_pressed():
	var dto=MapDTO.new()
	dto.restore("asdf")
	dto.delete()
	pass # Replace with function body.
