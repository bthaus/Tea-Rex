extends Node2D

var map_id: String
var map_name: String
var author: String
var wave_lengths: Array[int] #Contains all allowed wave lengths so 1-5 -> [1, 2, 3, 4, 5]
var clear_rate_up_to: float #Value between 0.0 and 1.0, 
var sort_by: String
var page_number: int = 1
const PAGE_SIZE: int = 10

func init_search_properties(map_id: String, map_name: String, author: String, wave_lengths: Array[int], clear_rate_up_to: float):
	self.map_id = map_id
	self.map_name = map_name
	self.author = author
	self.wave_lengths = wave_lengths
	self.clear_rate_up_to = clear_rate_up_to

func update_container():
	var sort_by = $SortOptionButton.get_item_text($SortOptionButton.get_selected_id())
	var order_by = $OrderByOptionButton.get_item_text($OrderByOptionButton.get_selected_id())
	var level_list = ServerDTOs.get_list_level_dto(map_id, map_name, author, wave_lengths, clear_rate_up_to, sort_by, order_by, page_number, PAGE_SIZE)
	

func _on_back_button_pressed() -> void:
	var menu = SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_BROWSER_MENU)
	menu.init_search_properties(map_id, map_name, author, wave_lengths, clear_rate_up_to)
	SceneHandler.change_scene(menu)
