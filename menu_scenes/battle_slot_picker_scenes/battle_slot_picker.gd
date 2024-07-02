extends Node2D
class_name BattleSlotPicker
var map_name

# Called when the node enters the scene tree for the first time.
func _ready():
	var map_dto=MapDTO.new()
	map_dto.restore(map_name)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	MainMenu.change_content(load("res://Game/main_scene.tscn").instantiate())
	pass # Replace with function body.
