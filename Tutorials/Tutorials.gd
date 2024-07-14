extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	button_pressed=GameState.gameState.showTutorials;
	pass


func _on_toggled(toggled_on):
	if toggled_on:
		for k in TutorialHolder.tutNames.keys():
				GameSaver.save("0",k,"tutorials")
	GameState.gameState.showTutorials=toggled_on;
	
	
	pass # Replace with function body.
