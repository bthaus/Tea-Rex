extends Panel

var _map_dto: MapDTO

func set_level(map_dto: MapDTO):
	self._map_dto = map_dto
	$MapNameLabel.text = map_dto.map_name

func _on_view_button_pressed() -> void:
	pass # Replace
