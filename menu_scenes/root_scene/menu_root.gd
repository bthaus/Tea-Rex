extends GameObject2D
class_name MainMenu
static var level_select=load("res://menu_scenes/level_selector_scenes/level_selector.tscn").instantiate()
static var battle_slot_picker=load("res://menu_scenes/battle_slot_picker_scenes/battle_slot_picker.tscn").instantiate()
static var accounts=load("res://menu_scenes/account_tab_scenes/accounts_tab.tscn").instantiate()
static var level_editor=load("res://LevelEditor/level_editor.tscn").instantiate()

static var instance; 
static var account_dto:AccountInfoDTO


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
	
static func select_account(account_dto:AccountInfoDTO):
	account_dto=account_dto
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	change_content(accounts)
	pass # Replace with function body.


func _on_back_pressed():
	if scene_stack.size()==1:return;
	remove_child(scene_stack.pop_back())
	add_child(scene_stack.back())
	pass # Replace with function body.


func _on_button_pressed():
	change_content(level_editor)
	pass # Replace with function body.
