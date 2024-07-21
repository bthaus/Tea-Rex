extends Panel

@onready var spawner_item_container = $SpawnerScrollContainer/SpawnerItemContainer
@onready var wave_number_edit = $WaveNumber/WaveNumberEdit
@onready var wave_number_error_label = $WaveNumber/WaveNumberErrorLabel

var _spawner_settings_count: int
var _current_wave = 0
var _number_of_waves: int

var _copied_monsters = null

func _ready():
	_number_of_waves = wave_number_edit.text as int

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
	
	_spawner_settings_count -= 1
	_update_items(_current_wave)

func add_spawner_setting():
	var item = load("res://LevelEditor/ContainerItems/spawner_settings_item.tscn").instantiate()
	spawner_item_container.add_child(item)
	item.set_spawner_id(_spawner_settings_count)
	item.set_number_of_waves(_number_of_waves)
	item.copy.connect(_on_spawner_copy)
	item.paste.connect(_on_spawner_paste)
	_spawner_settings_count += 1
	_update_items(_current_wave)

func _update_items(wave: int):
	for item in spawner_item_container.get_children():
		item.update_items(wave)

func _set_number_of_waves(amount: int):
	for item in spawner_item_container.get_children():
		item.set_number_of_waves(amount)

func _on_spawner_copy(monster_counts: Array):
	_copied_monsters = monster_counts

func _on_spawner_paste(sender):
	if _copied_monsters == null:
		return
	sender.set_monsters_for_wave(_current_wave, _copied_monsters)
	
#Returns this format
#   ---> MonsterWaveDTO of all spawners
# |
# |
# v Waves
func get_monster_waves():
	var monster_waves = []
	monster_waves.resize(_number_of_waves)
	for i in monster_waves.size(): monster_waves[i] = []
	
	for item in spawner_item_container.get_children():
		var i = 0
		for spawner in item.get_spawner():
			for waves in spawner:
				monster_waves[i].append(waves)
			i += 1
	
	return monster_waves


func _on_next_wave_button_pressed():
	if _current_wave < _number_of_waves - 1:
		_current_wave += 1
		_set_current_wave(_current_wave)

func _on_previous_wave_button_pressed():
	if _current_wave > 0:
		_current_wave -= 1
		_set_current_wave(_current_wave)

func _set_current_wave(wave: int):
	$WaveLabel.text = str("Wave: ", wave+1)
	_update_items(wave)


func _on_wave_number_set_button_pressed():
	wave_number_error_label.visible = false
	var waves_text = wave_number_edit.text.strip_edges()
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(waves_text)
	if not result or result.get_string() != waves_text:
		wave_number_error_label.text = "Invalid Input!"
		wave_number_error_label.visible = true
		wave_number_edit.text = str(_number_of_waves) #Reset to original value
		return
	
	var waves = waves_text as int
	if waves < GameplayConstants.MIN_NUMBER_OF_WAVES or waves > GameplayConstants.MAX_NUMBER_OF_WAVES:
		wave_number_error_label.text = str("Must be in range ", GameplayConstants.MIN_NUMBER_OF_WAVES, " - ", GameplayConstants.MAX_NUMBER_OF_WAVES)
		wave_number_error_label.visible = true
		wave_number_edit.text = str(_number_of_waves) #Reset to original value
		return

	if waves == _number_of_waves: #Value is already set
		return
		
	#Update waves
	if _current_wave >= waves: #If we edit wave 10 for example but now only have 5 anymore, set _current_wave to 5.
		_current_wave = waves - 1
		_set_current_wave(_current_wave)
		
	_number_of_waves = waves
	_set_number_of_waves(_number_of_waves)

func _on_close_button_pressed():
	hide()
