extends Panel

var map_name: String

func set_map(map_name: String):
	self.map_name = map_name
	$NameLabel.text = map_name
	
func _on_edit_button_pressed():
	var map_dto = MapDTO.new()
	map_dto.restore(map_name)
	MainMenu.change_content(MainMenu.level_editor)
	MainMenu.level_editor.load_map(map_dto)


func _on_play_button_pressed():
	var picker = MainMenu.battle_slot_picker.duplicate()
	picker.map_name=name
	MainMenu.change_content(picker)
