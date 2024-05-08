extends Node2D
class_name Tutorial;
var seen=false;
var title="hi man"
var done:Callable;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
	$Text.add_theme_font_size_override("normal_font_size",24)
	$Title.add_theme_font_size_override("normal_font_size",45)
	$Text.add_theme_font_size_override("bold_font_size",24)
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
	GameState.gameState.gameBoard.ignore_input=false;
	seen=true;
	done.call()
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",Color(0,0,0,0),1)
	tween.tween_callback(func():queue_free())
	
	
	pass # Replace with function body.
