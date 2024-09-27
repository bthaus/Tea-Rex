extends Panel

var map_dto: MapDTO
var level

func set_level(level):
	self.level = level
	map_dto = level["map_dto"]
	$MapNameLabel.text = map_dto.map_name

func _on_view_button_pressed() -> void:
	var web_level = SceneHandler.get_scene_instance(SceneHandler.Scene.WEB_LEVEL_PREVIEW)
	web_level.set_level(level)
	SceneHandler.change_scene(web_level)
