extends GameObject2D
class_name BattleSlotPicker
var map_name
var map
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



func _on_button_pressed():
	var game_state=load("res://Game/main_scene.tscn").instantiate()
	game_state.map_dto=map
	MainMenu.change_content(game_state)
	pass # Replace with function body.
