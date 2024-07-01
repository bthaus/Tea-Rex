extends Node2D
class_name MainMenu

static var instance; 
# Called when the node enters the scene tree for the first time.
func _ready():
	
	instance=self;
	scene_stack.push_back(start_game_scene)
	pass # Replace with function body.
	
@onready var start_game_scene=$start_page
static var scene_stack:Array=[]

static func change_content(scene):
	instance.remove_child(scene_stack.back())
	instance.add_child(scene)
	scene_stack.push_back(scene)
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	change_content(load("res://menu_scenes/level_selector.tscn").instantiate())
	pass # Replace with function body.


func _on_back_pressed():
	if scene_stack.size()==1:return;
	remove_child(scene_stack.pop_back())
	add_child(scene_stack.back())
	pass # Replace with function body.
