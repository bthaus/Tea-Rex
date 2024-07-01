extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_button_pressed():
	MainMenu.change_content(load("res://menu_scenes/battle_slot_picker.tscn").instantiate())
	pass # Replace with function body.
