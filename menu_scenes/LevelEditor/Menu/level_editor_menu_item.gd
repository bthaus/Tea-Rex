extends Panel

var map_name: String
signal delete

func set_map(map_dto: MapDTO):
	self.map_name = map_dto.map_name
	$NameLabel.text = map_dto.map_name
	$MapPreview.set_map(map_dto, false)
	
func _on_edit_button_pressed():
	var map_dto = MapDTO.new()
	map_dto.restore(map_name)
	var level_editor = SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_EDITOR)
	SceneHandler.change_scene(level_editor)
	level_editor.load_map(map_dto)

func _on_play_button_pressed():
	Global.is_playing_custom_level = true
	var picker = SceneHandler.get_scene_instance(SceneHandler.Scene.BATTLE_SLOT_PICKER)
	picker.map_name = map_name
	SceneHandler.change_scene(picker)
	picker.enable_sandbox_mode()


func _on_delete_button_pressed():
	delete.emit(self)
