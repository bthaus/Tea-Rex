extends Node2D
class_name Menu
@export var gamestate:GameState
signal statePropagation(gamestate:GameState)

# Called when the node enters the scene tree for the first time.
func _ready():
	statePropagation.emit(gamestate)
	pass # Replace with function body.
func updateUI():
	
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_battle_phase_pressed():
	gamestate.startBattlePhase()
	pass # Replace with function body.


func _on_start_button_pressed():
	pass # Replace with function body.
