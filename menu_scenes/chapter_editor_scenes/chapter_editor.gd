extends Control

var chapters:MapChapterDTO
var current_map_name=""
var unused_maps
# Called when the node enters the scene tree for the first time.
func _ready():
	unused_maps=$all_maps
	chapters=MapChapterDTO.new()
	chapters.restore()
	refresh_all_cols()
			
	pass # Replace with function body.

func refresh_all_cols():
	for child in get_children():
		if child!=unused_maps:
			child.queue_free()
	$all_maps/maps.clear()		
	for unused in chapters.get_maps_without_chapter():
		$all_maps/maps.add_item(unused)	
	for key in chapters.chapter_dictionary.keys():
		var col=ChapterCollumn.create(key,chapters.chapter_dictionary[key]) as ChapterCollumn
		col.chapter_deleted.connect(delete_chapter)
		col.chapter_pressed.connect(try_move_to_chapter)
		col.map_removed.connect(remove_map_from_chapter)
		add_child(col)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func delete_chapter(chaptername):
	chapters.remove_chapter(chaptername)
	refresh_all_cols()
	pass;
func try_move_to_chapter(chaptername):
	if current_map_name=="":return
	
	chapters.add_map_to_chapter(current_map_name,chaptername)
	current_map_name=""
	refresh_all_cols()
		
		
	pass;
	
func remove_map_from_chapter(chaptername,mapname):
	chapters.remove_map_from_chapter(mapname,chaptername)
	refresh_all_cols()
	pass;	
func map_selected(chapter_name, map_name):
	
	pass;

func _on_all_maps_item_clicked(index, at_position, mouse_button_index):
	current_map_name=$all_maps/maps.get_item_text(index)
	
	pass # Replace with function body.





func _on_chapter_adder_text_submitted(new_text):
	chapters.add_chapter(new_text)
	refresh_all_cols()
	pass # Replace with function body.
