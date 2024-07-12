extends Control
class_name InfoBox
var inspected=false
var strings
static var current
static var scene=load("res://menu_scenes/info_box_scenes/info_box.tscn").instantiate()
static func create(strings:Array[String]):
	var ret=scene.duplicate()
	ret.strings=strings
	if current!=null:
		if not current.inspected:
			current.queue_free()
		else: return	
	current=ret
	return ret
	

func _ready():
	for string in strings:
		var label=Label.new()
		label.text=string
		label.tooltip_text="does this work?"
		
		$info_box.add_child(label)
	pass



func delayed_delete():
	get_tree().create_timer(0.5).timeout.connect(poll_delete)
	pass;
func poll_delete():
	if not inspected:
		queue_free()
	pass;




func _on_mouse_entered():
	inspected=true
	pass # Replace with function body.


func _on_mouse_exited():
	
	inspected=false;
	delayed_delete()
	pass # Replace with function body.
