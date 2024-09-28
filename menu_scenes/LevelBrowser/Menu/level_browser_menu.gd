extends Node2D

var search_options = {
	"Map Name": 0,
	"Map ID": 1,
	"Author": 2
}

func init_search_properties(map_id: String, map_name: String, author: String, wave_lengths: Array[int], clear_rate_up_to: float):
	if map_name != "": 
		$SearchByOptionButton.selected = search_options.get("Map Name")
		$SearchEdit.text = map_name
	if map_id != "": 
		$SearchByOptionButton.selected = search_options.get("Map ID")
		$SearchEdit.text = map_id
	if author != "": 
		$SearchByOptionButton.selected = search_options.get("Author")
		$SearchEdit.text = author
	
	if wave_lengths.has(1): $VeryShortCheckBox.button_pressed = true
	if wave_lengths.has(6): $ShortCheckBox.button_pressed = true
	if wave_lengths.has(11): $MediumCheckBox.button_pressed = true
	if wave_lengths.has(21): $LongCheckBox.button_pressed = true
	if wave_lengths.has(51): $XLCheckBox.button_pressed = true
	
	$ClearRateSlider.value = clear_rate_up_to * 100
	$ClearRatePercentLabel.text = str("<=", $ClearRateSlider.value, "%")

func _on_search_button_pressed() -> void:
	var map_id = "" 
	var map_name = ""
	var author = ""
	var selected_text = $SearchByOptionButton.get_item_text($SearchByOptionButton.get_selected_id())
	if selected_text == "Map Name": map_name = $SearchEdit.text
	elif selected_text == "Map ID": map_id = $SearchEdit.text
	elif selected_text == "Author": author = $SearchEdit.text
	
	var wave_lengths: Array[int] = []
	if $VeryShortCheckBox.button_pressed: wave_lengths.append_array(range(1, 6))
	if $ShortCheckBox.button_pressed: wave_lengths.append_array(range(6, 11))
	if $MediumCheckBox.button_pressed: wave_lengths.append_array(range(11, 21))
	if $LongCheckBox.button_pressed: wave_lengths.append_array(range(21, 51))
	if $XLCheckBox.button_pressed: wave_lengths.append_array(range(51, GameplayConstants.MAX_NUMBER_OF_WAVES+1))
	
	var clear_rate_up_to = $ClearRateSlider.value / 100.0
	
	var browser = SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_BROWSER)
	browser.init_search_properties(map_id, map_name, author, wave_lengths, clear_rate_up_to)
	SceneHandler.change_scene(browser)


func _on_clear_rate_slider_value_changed(value: float) -> void:
	$ClearRatePercentLabel.text = str("<=", value, "%")


func _on_start_button_pressed() -> void:
	pass # Replace with function body.
