extends Node2D

@onready var level_rows_container = $ScrollContainer/MarginContainer/LevelRowsContainer
const LEVEL_COLUMNS = 6
const ITEM_SEPERATION = 75


func _ready():
	level_rows_container.add_theme_constant_override("separation", ITEM_SEPERATION)
	set_levels("")

func set_levels(chapter_name: String):
	
	for child in level_rows_container.get_children():
		level_rows_container.remove_child(child)
		child.queue_free()
	
	#var chapters=MapChapterDTO.new()
	#chapters.restore()
	#var level_names = chapters.get_mapnames_from_chapter(chapter_name)
	var level_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
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
