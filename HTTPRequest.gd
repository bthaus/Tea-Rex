extends HTTPRequest


func _ready():
	request_completed.connect(_on_request_completed)
	send()
	#request("http://localhost:8080/hello")
func send():
	#var map=MapDTO.new()
	#map.restore("sim_debug")
	#var dto=ServerDTOs.get_map_dto(map,1)
	##var json = JSON.stringify(map.get_json())
	##var json=JSON.stringify({"id"=1,
	##"name"="Bodo",
	##"email"="bweust"})
	#var json=JSON.stringify(dto)
	#var headers = ["Content-Type: application/json"]
	#request("http://localhost:8080/add_map", headers, HTTPClient.METHOD_POST, json)
	request("http://localhost:8080/get_map/2")
	pass;
func _on_request_completed(result, response_code, headers, body):
	#request("http://localhost:8080/hello")
	var json = body.get_string_from_utf8()
	var data=JSON.parse_string(json)
	print(json)
