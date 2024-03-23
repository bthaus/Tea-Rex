extends Node2D
class_name Monster;
@export var sizemult=1;


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hitbox/Hitboxshape.apply_scale(Vector2(sizemult,sizemult));

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_pressed("testdown")):
		translate(Vector2(500*delta,500*delta))
	if(Input.is_action_pressed("testup")):
		translate(Vector2(-500*delta,-500*delta))
	pass
