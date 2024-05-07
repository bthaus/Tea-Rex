extends Node2D
class_name Tutorial;
var seen=false;
var title="hi man"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func isSeen():
	var s=GameSaver.loadfile(name,"tutorials")
	if s=="1":
		seen=true;
	return seen;
	pass;
func _on_button_pressed():
	GameSaver.save("1",name,"tutorials")
	print(name)
	hide()
	seen=true;
	
	pass # Replace with function body.
