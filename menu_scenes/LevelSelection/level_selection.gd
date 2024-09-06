extends Node2D


func set_levels(chapter_name: String):
	var chapters=MapChapterDTO.new()
	chapters.restore()
	var level_names = chapters.get_mapnames_from_chapter(chapter_name)
	for level in level_names:
		var item = load("res://menu_scenes/LevelSelection/level_selection_item.tscn")
		item.set_level(level)
