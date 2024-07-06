extends Control
class_name MapPreview_MenuItem
var map_name:String=""
var progress_dto
signal selected(mapname)
var account_dto;
# Called when the node enters the scene tree for the first time.
func _ready():
	$map_preview.text=map_name
	account_dto=MainMenu.get_account_dto()
	progress_dto=account_dto.get_map_progress_dto_by_name(map_name)
	$map_preview/stars.text=str(progress_dto.stars_unlocked)
	pass # Replace with function body.
static func create(name)-> MapPreview_MenuItem:
	var instance=load("res://menu_scenes/level_selector_scenes/map_preview.tscn").instantiate() as MapPreview_MenuItem
	instance.map_name=name
	return instance
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_pressed():
	pass # Replace with function body.


func _on_map_preview_pressed():
	
	selected.emit(map_name)
	pass # Replace with function body.
