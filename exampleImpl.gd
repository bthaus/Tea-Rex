@tool
extends Node2D
class_name collider;
@export var  test:Texture2D;
@export var coll:collider;

# Called when the node enters the scene tree for the first time.
func _ready():
	coll.halleo();
	coll.halleo();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func halleo():
	
	pass
	
func _get_configuration_warnings():
	var arr=PackedStringArray([])
	var parent=get_parent()
	if(parent==null):
		arr.append("This is a dangling Inv Rep. Put into an item")
	if(!parent.has_method("activate_item")):
		arr.append("Parent node needs activate_item() method.")
		return arr;
