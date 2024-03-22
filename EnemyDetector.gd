extends Node2D
@export var rangeMult=1;



# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D/detectionshape.scale=rangeMult;
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
