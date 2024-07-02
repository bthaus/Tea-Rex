extends Panel

@onready var spawner_item_container = $SpawnerScrollContainer/SpawnerItemContainer

var spawner_settings_count: int

func remove_spawner_setting(spawner_id: int):
	#Remove the spawner with the id
	for child in spawner_item_container.get_children():
		if child.get_spawner_id() == spawner_id:
			child.queue_free()
			break
	
	#Rename all others so there is no hole in the ids
	for child in spawner_item_container.get_children():
		if child.get_spawner_id() > spawner_id:
			child.set_spawner_id(child.get_spawner_id() - 1)
	
	spawner_settings_count -= 1

func add_spawner_setting():
	var item = load("res://LevelEditor/ContainerItems/spawner_settings_item.tscn").instantiate()
	spawner_item_container.add_child(item)
	item.set_spawner_id(spawner_settings_count)
	spawner_settings_count += 1

func _on_close_button_pressed():
	hide()
