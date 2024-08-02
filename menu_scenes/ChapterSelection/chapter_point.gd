extends Button
class_name ChapterPoint

@export var index: int
@export var next_point_path: Path2D

signal clicked

func _on_pressed():
	clicked.emit(self)
