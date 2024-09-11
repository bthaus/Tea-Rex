extends HTTPRequest
const server_base_route="http://localhost:8080/"
const public_key="-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwsx2ZQWdfQoNmqjfjkjK
ucTmFY5F+vdieEFMFcwGjZWA/l7tXb+gVtVNA0BDi6wwv+FBjup/HObV5K5Ky1H1
Ht1qUlTSal5TYROsgIS+oejje2s63kmi11/WxmQszl1tFhr2o4VqoQtImPhb36CW
vyskDxsIcu3O5Etr/VPfQdA2LrrOUQqtIAwRyyX1LZC7Ezw9Wo/yDUVsYmCrWJ+T
NM40wGSD+kzd9AewhIesDEPxFwMocsPRe3RcK38qOciRrgy91X9qwR53YhsA2u3+
RId3M1iJcfdLPR99dGDVhR5i6P2SdpHEmdp8NfoBGkaR7vIs9LLHVigWiQCCBEEx
CQIDAQAB
-----END PUBLIC KEY-----
"
var token=""
func _on_request_completed(result, response_code, headers, body):
	#request("http://localhost:8080/hello")
	check_for_token(headers)
	var json = body.get_string_from_utf8()
	var data=JSON.parse_string(json)
	print(json)

func check_for_token(headers):
	
	for s:String in headers:
		if s.contains("token"):
			token=s.substr(s.find("=")+1)+"hi"
			var dto=Global.get_account()
			dto._active_token=token
			dto.save()
	pass;
func get_headers():
	var tokencookie="token="+token
	return  ["Content-Type: application/json","Cookie: "+tokencookie]
func _ready():
	request_completed.connect(_on_request_completed)
	Global.set_account(AccountInfoDTO.new())
	Global.get_account().account_name = "JohnDoe"+str(randi_range(0,100000))
	send()
	#request("http://localhost:8080/hello")
	
func encrypt(s:String)->PackedByteArray:
	var key=CryptoKey.new()
	key.load_from_string(public_key,true)
	var crypto=Crypto.new()
	var buf=s.to_utf8_buffer()
	var encrypted=crypto.encrypt(key,buf)
	return encrypted
	pass;	
func send():
	
	
	pass;

func POST(route,data_dic):
	
	var json=JSON.stringify(data_dic)
	request(server_base_route+route, get_headers(), HTTPClient.METHOD_POST, json)
	pass;
func GET(route):
	request(server_base_route+route,get_headers())
	pass;	
func send_map(map_dto:MapDTO):
	var id=Global.get_account().account_name
	var dto=ServerDTOs.get_map_dto(map_dto,id)
	POST("validated/add_map",dto)
	pass;	
func get_map(map_name:String):
	GET("get_map/"+map_name)
	pass;	
func send_comment(comment:String,mapname:String):
	var id=Global.get_account().account_name
	var dto=ServerDTOs.get_comment_dto(comment,id,mapname)
	POST("validated/add_comment",dto)
	pass;	
func get_comments(mapname:String):
	GET("get_comments_from_map/"+mapname)
	pass;	

func _on_sen_pressed():
	send_comment("geile map","sim_debug")
	pass # Replace with function body.


func _on_get_pressed():
	get_comments("sim_debug")
	pass # Replace with function body.


func _on_map_pressed():
	var map=MapDTO.new()
	map.restore("sim_debug")
	send_map(map)

	pass # Replace with function body.


func _on_button_pressed():
	get_map("sim_debug")
	pass # Replace with function body.

func get_maps_from_user(username):
	GET("get_maps_from_user/"+username)
	
func _on_get_maps_from_user_pressed():
	get_maps_from_user("JohnDoe")
	pass # Replace with function body.

func add_rating_to_map(rating:int,map_name:String,user_name:String):
	var dto=ServerDTOs.get_rating_dto(map_name,user_name,rating);
	POST("validated/add_rating_to_map",dto)
func get_rating_from_map(map_name:String):
	GET("get_rating_from_map/"+map_name)	
func _on_button_2_pressed():
	add_rating_to_map(5,"sim_debug","JohnDoe")
	pass # Replace with function body.


func _on_get_rating_pressed():
	get_rating_from_map("sim_debug")
	pass # Replace with function body.

func register_user(username,password,email):
	var data=ServerDTOs.get_account_dto(username,password,email)
	POST("register_acc",data)
func _on_addacc_pressed():
	register_user(Global.get_account().account_name,"bodopw","bwuest@gmx.at"+str(randi_range(10,1111322)))
	pass # Replace with function body.
