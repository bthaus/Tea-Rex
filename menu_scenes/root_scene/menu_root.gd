extends GameObject2D
class_name MainMenu
static var level_select=load("res://menu_scenes/level_selector_scenes/level_selector.tscn").instantiate()
static var battle_slot_picker=load("res://menu_scenes/battle_slot_picker_scenes/battle_slot_picker.tscn").instantiate()
static var accounts=load("res://menu_scenes/account_tab_scenes/accounts_tab.tscn").instantiate()
static var level_editor_menu=load("res://LevelEditor/Menu/level_editor_menu.tscn").instantiate()
static var level_editor=load("res://LevelEditor/level_editor.tscn").instantiate()
static var win_screen=load("res://menu_scenes/win_screen_scenes/win_scene.tscn").instantiate()
static var chapter_editor=load("res://menu_scenes/chapter_editor_scenes/chapter_editor.tscn").instantiate()
static var instance; 
static var account_dto:AccountInfoDTO=AccountInfoDTO.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	instance=self;
	scene_stack.push_back(start_game_scene)
	pass # Replace with function body.
	
@onready var start_game_scene=$start_page
static var scene_stack:Array=[]
static func get_account_dto()->AccountInfoDTO:
	var dto= account_dto
	return dto
	pass;
static func change_content(scene):
	var to_remove=scene_stack.back()
	instance.remove_child(to_remove)
	instance.add_child(scene)
	scene_stack.push_back(scene)
	pass;
	
static func select_account(dto:AccountInfoDTO):
	account_dto=dto
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	change_content(accounts)
	pass # Replace with function body.


func _on_back_pressed():
	if scene_stack.size()==1:return;
	var to_remove=scene_stack.pop_back()
	remove_child(to_remove)
	add_child(scene_stack.back())
	pass # Replace with function body.


func _on_button_pressed():
	change_content(level_editor_menu)
	pass # Replace with function body.


func _on_delete_all_pressed():
	var dir=DirAccess.open("user://maps")
	
	var dirs=[]
	delete_dir(dir,dirs)
	var root=DirAccess.open("user://")
	
	dirs.reverse()	
	for directory in dirs:
		directory.erase(0,7)
		root.remove(directory)
		
	dirs.clear()	
	
	pass # Replace with function body.

func delete_dir(dir:DirAccess,dirs:Array):
	if dir==null:return
	for file in dir.get_files():
		dir.remove(file)
	
	dirs.append(dir.get_current_dir())
	for d in dir.get_directories():
		var temp=DirAccess.open(dir.get_current_dir()+"/"+d )
		delete_dir(temp,dirs)
	pass;


func _on_delete_all_accounts_pressed():
	var dir=DirAccess.open("user://acc_infos")	
	var dirs=[]
	
	var root=DirAccess.open("user://")
	delete_dir(dir,dirs)
	
	dirs.reverse()	
	for directory in dirs:
		directory.erase(0,7)
		root.remove(directory)	
	pass # Replace with function body.


func _on_chapter_editor_pressed():
	change_content(chapter_editor)
	pass # Replace with function body.
