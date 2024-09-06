extends Node2D

@onready var level_rows_container = $ScrollContainer/MarginContainer/LevelRowsContainer
const LEVEL_COLUMNS = 6
const ITEM_SEPERATION = 75
var level_names: Array
var path_points: Array

func _ready():
	level_rows_container.add_theme_constant_override("separation", ITEM_SEPERATION)
	set_levels("")
	await get_tree().process_frame
	set_paths()
	queue_redraw()

func set_levels(chapter_name: String):
	
	for child in level_rows_container.get_children():
		level_rows_container.remove_child(child)
		child.queue_free()
	
	#var chapters=MapChapterDTO.new()
	#chapters.restore()
	#var level_names = chapters.get_mapnames_from_chapter(chapter_name)
	level_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
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
		item.set_level(level)
		level_rows_container.get_child(row).add_child(item)
		if row % 2 == 1:
			level_rows_container.get_child(row).move_child(item, 0) #Reverse order for odd-numbered rows
		idx += 1

func set_paths():
	var row = 0
	var idx = 0
	path_points.clear()
	for container in level_rows_container.get_children():
		var items = container.get_children()
		if row % 2 == 1: items.reverse()
		var col = 0
		for item in items:
			if not item.unlocked: #This was the last level that is unlocked
				return
			idx += 1
			if level_names.size() == idx: #It is the last level
				return
			
			var next_item
			if col < items.size() - 1:
				next_item = items[col + 1]
			else:
				var cont = level_rows_container.get_child(row+1)
				if (row + 1) % 2 == 0: next_item = cont.get_child(0) #First item
				else: next_item = cont.get_child(cont.get_child_count()-1) #Last item
			
			path_points.append(Connection.new(item.global_position + item.size/2, next_item.global_position + next_item.size/2))
			col += 1
			
		row += 1

func _draw():
	for point in path_points:
		draw_line(point.from, point.to, Color.WHITE, 2.0, true)

class Connection:
	var from: Vector2
	var to: Vector2
	func _init(from: Vector2, to: Vector2):
		self.from = from
		self.to = to
