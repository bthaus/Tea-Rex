extends HTTPRequest


func _ready():
	request_completed.connect(_on_request_completed)
	send()
	#request("http://localhost:8080/hello")
func send():
	var map=MapDTO.new()
	map.restore("sim_debug")
	map.save("sim_debug")
	var json = JSON.stringify(map.get_json())
	var headers = ["Content-Type: application/json"]
	request("http://localhost:8080/post_map", headers, HTTPClient.METHOD_POST, json)
	pass;
func _on_request_completed(result, response_code, headers, body):
	request("http://localhost:8080/hello")
	var json = body.get_string_from_utf8()
	print(json)
