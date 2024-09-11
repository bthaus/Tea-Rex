extends Panel

var map_name: String

func set_map(map_dto: MapDTO):
	self.map_name = map_dto.map_name
	$NameLabel.text = map_dto.map_name
	$MapPreview.set_map(map_dto, false)
	
func _on_edit_button_pressed():
	var map_dto = MapDTO.new()
	map_dto.restore(map_name)
	var level_editor = MainMenu.get_scene_instance(MainMenu.LEVEL_EDITOR_PATH)
	MainMenu.change_content(level_editor)
	level_editor.load_map(map_dto)

func _on_play_button_pressed():
	var picker = MainMenu.get_scene_instance(MainMenu.BATTLE_SLOT_PICKER_PATH)
	picker.map_name = map_name
	MainMenu.change_content(picker)
	picker.enable_sandbox_mode()

