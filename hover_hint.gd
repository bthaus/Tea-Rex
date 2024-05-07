extends Node2D
@export var hintText:Label;

# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_parent())
	$Button.modulate=Color(0,0,0,0)
	pass # Replace with function body.

var hovered=false
var t=0;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hintText==null:queue_free();return
	if hovered and t<1:
		t=t+2*delta;
		
	if not hovered and t>0:
		t=t-2*delta;
		
	t=clamp(t,0,1)
	hintText.modulate=Color(1,1,1,t);
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
