extends Node2D

@onready var level_rows_container = $ScrollContainer/MarginContainer/LevelRowsContainer

var level_names: Array
const LEVEL_COLUMNS = 6
const ITEM_SEPERATION = 75

const PATH_DASHES = 3
const PATH_SPACE = 20
const PATH_WIDTH = 8
const PATH_OFFSET = 15
var path_color: Color = Color.WHITE

var new_level_unlocked: bool = false

func _ready():
	level_rows_container.add_theme_constant_override("separation", ITEM_SEPERATION)

func set_levels(chapter_name: String):
	level_rows_container.add_theme_constant_override("separation", ITEM_SEPERATION)
	for child in level_rows_container.get_children():
		level_rows_container.remove_child(child)
		child.queue_free()
	
	var chapters=MapChapterDTO.new()
	chapters.restore()
	level_names = chapters.get_mapnames_from_chapter(chapter_name)
	
	var idx = 0
	var row = -1
	for level in level_names:
		if idx % LEVEL_COLUMNS == 0: #Add a new row
			row += 1
			var container = HBoxContainer.new()
			container.add_theme_constant_override("separation", ITEM_SEPERATION)
			container.alignment = BoxContainer.ALIGNMENT_BEGIN if row % 2 == 0 else BoxContainer.ALIGNMENT_END
			level_rows_container.add_child(container)
		
		var item = load("res://menu_scenes/LevelSelection/level_selection_item.tscn").instantiate()
		var map_dto = MapDTO.new()
		map_dto.restore(level)
		item.set_map(map_dto)
		level_rows_container.get_child(row).add_child(item)
		if row % 2 == 1:
			level_rows_container.get_child(row).move_child(item, 0) #Reverse order for odd-numbered rows
		idx += 1
	
	call_deferred("set_path")

func set_path():
	var paths = get_level_paths()
	var idx = 0
	for path in paths:
		var lines = get_lines_from_path(path, PATH_DASHES, PATH_SPACE, PATH_WIDTH, path_color)
		if new_level_unlocked and idx + 1 == paths.size(): #Last element, and it got just unlocked
			var delay = 1
			for line in lines:
				line.modulate.a = 0
				get_tree().create_timer(delay).timeout.connect(func():
					get_tree().create_tween().tween_property(line, "modulate:a", 1, 1)
					)
				delay += 1
				add_child(line)
		else: #Draw paths normally
			for line in lines:
				add_child(line)
				
		idx += 1


func get_level_paths() -> Array[Path]:
	var row = 0
	var idx = 0
	var path_points: Array[Path] = []
	for container in level_rows_container.get_children():
		var items = container.get_children()
		if row % 2 == 1: items.reverse()
		var col = 0
		for item in items:
			if not item.unlocked: #This was the last level that is unlocked
				return path_points
			idx += 1
			if level_names.size() == idx: #It is the last level
				return path_points
			
			var next_item
			var item_path_offset #Offset based on middle point of the item
			var next_item_path_offset
			if col < items.size() - 1: #Both items are in the same row
				next_item = items[col + 1]
				if row % 2 == 0: #Left to right arrangement
					item_path_offset = Vector2(item.size.x/2 + PATH_OFFSET, 0)
					next_item_path_offset = Vector2(-(next_item.size.x/2 + PATH_OFFSET), 0)
				else:
					item_path_offset = Vector2(-(item.size.x/2 + PATH_OFFSET), 0)
					next_item_path_offset = Vector2(next_item.size.x/2 + PATH_OFFSET, 0)
			else: #New row switch
				var cont = level_rows_container.get_child(row+1)
				if (row + 1) % 2 == 0: next_item = cont.get_child(0) #First item
				else: next_item = cont.get_child(cont.get_child_count()-1) #Last item
				
				item_path_offset = Vector2(0, item.size.y/2 + PATH_OFFSET)
				next_item_path_offset = Vector2(0, -(next_item.size.y/2 + PATH_OFFSET))

			var item_path_pos = Vector2(item.global_position + item.size/2) + item_path_offset
			var next_item_path_pos = Vector2(next_item.global_position + next_item.size/2) + next_item_path_offset
			path_points.append(Path.new(item_path_pos, next_item_path_pos))
			col += 1
			
		row += 1
	return path_points

#https://math.stackexchange.com/questions/175896/finding-a-point-along-a-line-a-certain-distance-away-from-another-point
func get_lines_from_path(path: Path, number_of_dashes: int, space: int, width: int = 5.0, color: Color = Color.WHITE) -> Array[Line2D]:
	var lines: Array[Line2D] = []
	var path_length = sqrt(pow(path.to.x - path.from.x, 2) + pow(path.to.y - path.from.y, 2))
	var dash_length = (path_length - ((number_of_dashes - 1) * space)) / number_of_dashes
	
	var previous_point = path.from
	var total_distance = dash_length
	for dash in number_of_dashes:
		var t = total_distance/path_length #distance ratio
		var point = Vector2((1-t)*path.from.x + t*path.to.x, (1-t)*path.from.y + t*path.to.y)
		
		var line = Line2D.new()
		line.add_point(previous_point)
		line.add_point(point)
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.width = width
		line.default_color = color
		lines.append(line)
		
		total_distance += space #Add the space
		t = total_distance/path_length #distance ratio
		previous_point = Vector2((1-t)*path.from.x + t*path.to.x, (1-t)*path.from.y + t*path.to.y)
		total_distance += dash_length #Add the next dash distance
	
	return lines

class Path:
	var from: Vector2
	var to: Vector2
	func _init(from: Vector2, to: Vector2):
		self.from = from
		self.to = to
