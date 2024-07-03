extends GameObject2D
@export var hintText:Label;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Button.modulate=Color(0,0,0,0)
	#hintText.modulate=Color(0,0,0,0)
	pass # Replace with function body.

var hovered=false
var t=0;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(hintText,"modulate",Color(1,1,1,1),1)
	#hovered=true;
	pass # Replace with function body.


func _on_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property(hintText,"modulate",Color(0,0,0,0),1)
	#hovered=false;
	pass # Replace with function body.
