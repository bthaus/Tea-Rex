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
func _ready():
	request_completed.connect(_on_request_completed)
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
	
	#var dto=ServerDTOs.get_map_dto(map,1)
	#var crypto=Crypto.new()
	#var key=CryptoKey.new()
	#key.load_from_string(public_key)
	#var json = JSON.stringify(dto)
	#var u=encrypt("aasdasdfasdf")
	#
	#var json=JSON.stringify({"id"=1,
	##"name"="Bodo",
	##"email"="bweust"})
#	var json=JSON.stringify(dto)
	#var headers = ["Content-Type: application/json"]
#	request("https://localhost:443/add_map", headers, HTTPClient.METHOD_POST, json)
	#var client_trusted_cas = load("res://secrets/Neuer Ordner/ca_bundle.crt")
	#var client_tls_options = TLSOptions.client(client_trusted_cas)
	#set_tls_options(TLSOptions.client_unsafe())
	#set_tls_options(client_tls_options)
	#var data="mypassword"
	#var signature = crypto.sign(HashingContext.HASH_SHA256, data.sha256_buffer(), key)
	#print(signature)
	#var second_signature=crypto.sign(HashingContext.HASH_SHA256, data.sha256_buffer(), key)
	#print(signature==second_signature)

	#
	pass;

func POST(route,data_dic):
	var headers = ["Content-Type: application/json"]
	var json=JSON.stringify(data_dic)
	request(server_base_route+route, headers, HTTPClient.METHOD_POST, json)
	pass;
func GET(route):
	var headers = ["Content-Type: application/json"]
	request(server_base_route+route)
	pass;	
func send_map(map_dto:MapDTO):
	var id=MainMenu.get_account_dto().id
	var dto=ServerDTOs.get_map_dto(map_dto,"John Doe")
	POST("add_map",dto)
	pass;	
func get_map(map_name:String):
	GET("get_map/"+map_name)
	pass;	
func send_comment(comment:String,mapname:String):
	var id=MainMenu.get_account_dto().id
	var dto=ServerDTOs.get_comment_dto(comment,"John Doe",mapname)
	POST("add_comment",dto)
	pass;	
func get_comments(mapname:String):
	GET("get_comments_from_map/"+mapname)
	pass;	
func _on_request_completed(result, response_code, headers, body):
	#request("http://localhost:8080/hello")
	var json = body.get_string_from_utf8()
	var data=JSON.parse_string(json)
	print(json)


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
