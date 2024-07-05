extends GameObject2D

var map_items=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
func reorder_children():
	var children=get_children()
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


func _on_tree_entered():
	var name_dto=MapNameDTO.new()
	name_dto.restore()
	for child in get_children():
		child.queue_free()
	for name in name_dto.names:
		var item=MapPreview_MenuItem.create(name)
		map_items.push_back(item)
		item.selected.connect(_map_selected)
		add_child(item)
		
	reorder_children()	
	pass # Replace with function body.
