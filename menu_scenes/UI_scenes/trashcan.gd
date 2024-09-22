extends Sprite2D
class_name TrashCan

static var dumping=false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_mouse_entered() -> void:
	dumping=true
	pass # Replace with function body.


func _on_button_mouse_exited() -> void:
	dumping=false;
	pass # Replace with function body.
