extends Node2D
class_name MapPreview_MenuItem
var map_name:String=""
signal selected(mapname)
# Called when the node enters the scene tree for the first time.
func _ready():
	$map_name_button.text=map_name
	pass # Replace with function body.
static func create(name)-> MapPreview_MenuItem:
	var instance=load("res://menu_scenes/map_preview.tscn").instantiate() as MapPreview_MenuItem
	instance.map_name=name
	return instance
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_map_name_button_pressed():
	selected.emit(map_name)
	pass # Replace with function body.
