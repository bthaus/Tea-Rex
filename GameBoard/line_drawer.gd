extends Sprite2D
class_name linedrawer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var paths
func _draw():
	if paths==null:return;
	
	for dto in paths:
		var color = dto.color
		#color=color.lightened(1)
		var path=dto.path
		for i in range(1, path.size()):
			draw_line(Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y),
			Vector2(path[i].x - global_position.x, path[i].y - global_position.y), color, 3, true)
	
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
