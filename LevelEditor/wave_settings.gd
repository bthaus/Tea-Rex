extends Panel

@onready var spawner_item_container = $SpawnerScrollContainer/SpawnerItemContainer

var spawner_settings_count: int
var wave = 0
var numer_of_waves = 2

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
	_update_items(wave)

func add_spawner_setting():
	var item = load("res://LevelEditor/ContainerItems/spawner_settings_item.tscn").instantiate()
	spawner_item_container.add_child(item)
	item.set_spawner_id(spawner_settings_count)
	item.set_number_of_waves(numer_of_waves)
	spawner_settings_count += 1
	_update_items(wave)

func _update_items(wave: int):
	for item in spawner_item_container.get_children():
		item.update_items(wave)

func _set_number_of_waves(amount: int):
	for item in spawner_item_container.get_children():
		item.set_number_of_waves(amount)

#Returns this format
#   ---> MonsterWaveDTO of all spawners
# |
# |
# v Waves
func get_monster_waves():
	var monster_waves = []
	monster_waves.resize(numer_of_waves)
	for i in monster_waves.size(): monster_waves[i] = []
	
	for item in spawner_item_container.get_children():
		var i = 0
		for spawner in item.get_spawner():
			for waves in spawner:
				monster_waves[i].append(waves)
			i += 1
	
	return monster_waves


func _on_next_wave_button_pressed():
	if wave < numer_of_waves - 1:
		wave += 1
		_set_wave_text(wave)
		_update_items(wave)

func _on_previous_wave_button_pressed():
	if wave > 0:
		wave -= 1
		_set_wave_text(wave)
		_update_items(wave)

func _set_wave_text(wave: int):
	$WaveLabel.text = str("Wave: ", wave)

func _on_close_button_pressed():
	hide()

