extends Control
class_name ChapterCollumn
var chapter_name:String
var chapter_map_names:Array

signal map_selected(chapter_name,map_name)
signal chapter_deleted(chaptername)
signal chapter_pressed(chaptername)
signal map_removed(chaptername,mapname)
static func create(chaptername, chapter_map_names):
	var temp=load("res://menu_scenes/chapter_editor_scenes/chapter_collumn.tscn").instantiate()
	temp.chapter_name=chaptername
	temp.chapter_map_names=chapter_map_names
	return temp
	pass;
# Called when the node enters the scene tree for the first time.
func _ready():
	$chapter_name.text=chapter_name
	for name in chapter_map_names:
		$maps.add_item(name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_delete_pressed():
	chapter_deleted.emit(chapter_name)
	pass # Replace with function body.

var currently_selected=""
func _on_maps_item_activated(index):
	
	map_selected.emit(chapter_name,$maps.get_item_text(index))
	pass # Replace with function body.

func _on_select_pressed():
	chapter_pressed.emit(chapter_name)
	pass # Replace with function body.
func deselect_all():
	$maps.deselect_all()
	pass;

func _on_remove_pressed():
	if currently_selected=="": return
	map_removed.emit(chapter_name,currently_selected)
	pass # Replace with function body.


func _on_maps_item_clicked(index, at_position, mouse_button_index):
	currently_selected=$maps.get_item_text(index)
	map_selected.emit(currently_selected)
	pass # Replace with function body.
