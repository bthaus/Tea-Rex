extends Panel

var map_dto: MapDTO
signal delete

func set_map(map_dto: MapDTO):
	self.map_dto = map_dto
	$NameLabel.text = map_dto.map_name
	$MapPreview.set_map(map_dto, false)
	
func _on_edit_button_pressed():
	var level_editor = SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_EDITOR)
	SceneHandler.change_scene(level_editor)
	level_editor.load_map(map_dto)

func _on_play_button_pressed():
	var picker = SceneHandler.get_scene_instance(SceneHandler.Scene.BATTLE_SLOT_PICKER)
	picker.map_dto = map_dto
	SceneHandler.change_scene(picker)
	picker.enable_sandbox_mode()


func _on_delete_button_pressed():
	delete.emit(self)
