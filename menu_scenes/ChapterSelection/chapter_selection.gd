extends Node2D

var _current_point: ChapterPoint
var _move_to_point: ChapterPoint
var _is_moving = false
var _is_forward_direction = true
var _path_follow: PathFollow2D
var _previous_progress: float
var character = Sprite2D.new()
const CHARACTER_SPEED = 1.0

func _ready():
	character.texture = load("res://icon.svg")
	character.scale = Vector2(0.2, 0.2)
	for child in get_children():
		if child is ChapterPoint:
			if child.next_point_path != null:
				var path_follow = PathFollow2D.new()
				path_follow.rotates = false
				child.next_point_path.add_child(path_follow)
				if child.index == 0:
					_current_point = child
					_move_to_point = child
					child.next_point_path.get_child(0).add_child(character)
			child.clicked.connect(_on_chapter_point_clicked)

func _process(delta):
	if _current_point.index == _move_to_point.index and not _is_moving: return

	if not _is_moving:
		if _current_point.index < _move_to_point.index:
			var previous_point = _get_chapter_point_with_index(_current_point.index - 1)
			if previous_point != null: previous_point.next_point_path.get_child(0).remove_child(character)
			_path_follow = _current_point.next_point_path.get_child(0)
			_path_follow.add_child(character)
			_previous_progress = 0
			_path_follow.progress_ratio = 0
			_is_forward_direction = true
	
		if _current_point.index > _move_to_point.index:
			if _current_point.next_point_path != null: _current_point.next_point_path.get_child(0).remove_child(character)
			_current_point = _get_chapter_point_with_index(_current_point.index - 1)
			_path_follow = _current_point.next_point_path.get_child(0)
			_path_follow.add_child(character)
			_previous_progress = 1.0
			_path_follow.progress_ratio = 1.0
			_is_forward_direction = false
		_is_moving = true
	
	if _is_moving:
		if _is_forward_direction:
			_path_follow.progress_ratio += CHARACTER_SPEED * delta
			if _previous_progress > _path_follow.progress_ratio: #We have reached a point over 1.0
				_path_follow.progress_ratio = 1
				_current_point = _get_chapter_point_with_index(_current_point.index + 1)
				_is_moving = false
		else:
			_path_follow.progress_ratio -= CHARACTER_SPEED * delta
			if _previous_progress < _path_follow.progress_ratio: #We have reached a point under 0
				_path_follow.progress_ratio = 0
				_is_moving = false
		
		_previous_progress = _path_follow.progress_ratio

func set_character_to_chapter(chapter_name: String):
	var point = null
	for child in get_children():
		if child is ChapterPoint and child.chapter_name == chapter_name:
			point = child
			break
	if point == null:
		util.p(str("No chapter with name ", chapter_name, " found!"), "ChapterSelection")
		return
	
	_current_point.next_point_path.get_child(0).remove_child(character)
	_current_point = point
	_move_to_point = point
	
	if point.index > 0: #Not the starting point, add character to previous path follow
		var previous_point = _get_chapter_point_with_index(point.index - 1)
		_path_follow = previous_point.next_point_path.get_child(0)
		_path_follow.add_child(character)
		_path_follow.progress_ratio = 1
	else:
		point.next_point_path.get_child(0).add_child(character)


func _on_chapter_point_clicked(sender: ChapterPoint):
	if _move_to_point == sender: #TODO: SWITCH TO SCENE
		print(sender.chapter_name)

	if _is_moving:
		if sender.index > _move_to_point.index:
			_is_forward_direction = true
		if sender.index < _move_to_point.index:
			_is_forward_direction = false
	_move_to_point = sender

func _get_chapter_point_with_index(index: int) -> ChapterPoint:
	for child in get_children():
		if child is ChapterPoint and child.index == index:
			return child
	return null
