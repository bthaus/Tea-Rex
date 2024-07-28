extends GameObjectCounted
class_name ObjectHolder

var _objects = []

func _init():
	for row in GameboardConstants.BOARD_HEIGHT:
		var line = []
		for col in GameboardConstants.BOARD_WIDTH:
			line.append(null)
		_objects.append(line)

func insert_object(object, position: Vector2):
	_objects[position.y][position.x] = object

func get_object_at(position: Vector2):
	return _objects[position.y][position.x]

func pop_object_at(position: Vector2):
	var obj = _objects[position.y][position.x]
	_objects[position.y][position.x] = null
	return obj
