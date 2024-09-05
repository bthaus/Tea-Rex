extends GameObject2D
class_name BattleSlotPicker
var map_name
var map
var preview
# Called when the node enters the scene tree for the first time.
func _ready():
	var map_dto=MapDTO.new()
	map_dto.restore(map_name)
	map=map_dto
	
	#DELETE DELETE DELETE
	map.battle_slots = BattleSlotDTO.new()
	map.battle_slots.amount = 3
	
	$BlockSelector.set_map(map)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enable_sandbox_mode():
	$BlockSelector.enable_sandbox_mode()

var preview_map_name="preview_map"
var preview_map_turret_position=Vector2(9,6)
func _on_start_button_pressed():
	preview.free()
	var game_state = MainMenu.get_scene_instance(MainMenu.GAME_STATE_PATH)
	game_state.map_dto = map
	game_state.register_battle_slot_containers($BlockSelector.selected_containers)
	MainMenu.change_content(game_state)
func _on_tree_entered():
	preview=load("res://menu_scenes/turret_preview/Turret_preview_scene.tscn").instantiate() as Simulation
	preview.map_name=preview_map_name
	preview.auto_start=false
	preview.turret_position=preview_map_turret_position
	$preview_holder.add_child(preview)


func _on_tree_exited():
	util.erase(preview)
	pass # Replace with function body.
