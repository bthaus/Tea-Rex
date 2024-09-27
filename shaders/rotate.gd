extends MeshInstance3D

static var normal=Vector3(1,1,0).normalized()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_object_local(normal,delta/4)
	#rotate_y(delta/4)
	pass
