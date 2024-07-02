extends Panel

@onready var spawner_item_container = $SpawnerScrollContainer/SpawnerItemContainer

func set_spawner_settings(count: int):
	for child in spawner_item_container.get_children(): child.queue_free()
	for i in count:
		var item = load("res://LevelEditor/ContainerItems/spawner_settings_item.tscn").instantiate()
		spawner_item_container.add_child(item)

func _on_close_button_pressed():
	hide()
