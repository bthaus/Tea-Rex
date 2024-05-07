extends Node2D
class_name Tutorial;
var seen=false;
var title="hi man"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Vid.finished.connect(func():$Vid.play())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func isSeen():
	#if seen==true:
		#return seen;
	var s=GameSaver.loadfile(name,"tutorials")
	return s=="seen"
		
	pass;
func _on_button_pressed():
	GameSaver.save("seen",name,"tutorials")
	hide()
	GameState.gameState.gameBoard.ignore_input=false;
	seen=true;
	
	pass # Replace with function body.
