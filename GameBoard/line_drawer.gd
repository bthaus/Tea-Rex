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
			var from=Vector2(path[i-1].x - global_position.x, path[i-1].y - global_position.y)
			var to=Vector2(path[i].x - global_position.x, path[i].y - global_position.y)
			var distance=from.distance_to(to)
			if distance>80:
				continue
			draw_line(from,to, color, 3, true)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
