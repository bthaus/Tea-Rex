extends GameObject2D

var map_items=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
func reorder_children():
	var children=$levels.get_children()
	if children.is_empty():return;
	var off=clamp(800/get_child_count(),15,450)
	var offset=Vector2(-450,0)
	children.reverse()
	
	for c in children:
		offset=offset+Vector2(off,0)
		var tween=create_tween()
		if tween!=null:tween.tween_property(c,"global_position",global_position+offset,0.5).set_ease(Tween.EASE_IN_OUT)
		
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _map_selected(name):
	var picker=MainMenu.battle_slot_picker.duplicate()
	picker.map_name=name
	MainMenu.change_content(picker)
	pass # Replace with function body.

func chapter_selected(chapter):
	current_key=chapter
	_on_tree_entered()
	pass;
var current_key	
func _on_tree_entered():
	var chapters=MapChapterDTO.new()
	chapters.restore()
	
	for child in $chapters.get_children():
		child.queue_free()
	for key in chapters.chapter_dictionary.keys():
		if current_key==null:
			current_key=key
		var btn=Button.new()
		btn.text=key
		btn.pressed.connect(func():chapter_selected(key))
		$chapters.add_child(btn)
		
	
	for child in $levels.get_children():
		child.queue_free()
	for name in chapters.get_mapnames_from_chapter(current_key):
		var item=MapPreview_MenuItem.create(name)
		map_items.push_back(item)
		item.selected.connect(_map_selected)
		$levels.add_child(item)
		
	reorder_children()	
	pass # Replace with function body.
