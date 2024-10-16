extends Panel

@onready var spawner_item_container = $SpawnerScrollContainer/SpawnerItemContainer
@onready var wave_number_edit = $WaveNumber/WaveNumberEdit
@onready var wave_number_info_label = $WaveNumber/WaveNumberInfoLabel

var _spawner_settings_count = 0
var _current_wave = 0
var _number_of_waves: int

var _copied_monsters = null
var _copied_wave = null

func _ready():
	_number_of_waves = wave_number_edit.text as int
	_update_ui()

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
	_update_items_to_wave(_current_wave)
	_update_ui()

func add_spawner_setting():
	var item = load("res://menu_scenes/LevelEditor/WaveSettings/spawner_settings_item.tscn").instantiate()
	spawner_item_container.add_child(item)
	item.set_spawner_id(_spawner_settings_count)
	item.set_number_of_waves(_number_of_waves)
	item.copy.connect(_on_spawner_copy)
	item.paste.connect(_on_spawner_paste)
	_spawner_settings_count += 1
	_update_items_to_wave(_current_wave)
	_update_ui()

func _update_items_to_wave(wave: int):
	for item in spawner_item_container.get_children():
		item.update_items(wave)

func update_items():
	_update_items_to_wave(_current_wave)

func _set_number_of_waves(amount: int):
	for item in spawner_item_container.get_children():
		item.set_number_of_waves(amount)

func _on_spawner_copy(monster_counts: Array):
	_copied_monsters = monster_counts

func _on_spawner_paste(sender):
	if _copied_monsters == null:
		return
	sender.set_monsters_count_for_wave(_current_wave, _copied_monsters)


#Copies the spawners into this structure:
# ----> Monster count
# |
# |
# v Spawners
func _on_copy_button_pressed():
	_copied_wave = []
	for item in spawner_item_container.get_children():
		var monsters_count = item.get_monsters_count_for_wave(_current_wave)
		_copied_wave.append(monsters_count)
	
	$CopiedLabel.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($CopiedLabel, "position", $CopiedLabel.position + Vector2(0, -25), 1)
	tween.parallel()
	tween.tween_property($CopiedLabel, "modulate:a", 0, 1)
	tween.tween_callback(func(): $CopiedLabel.visible = false; $CopiedLabel.modulate.a = 1; $CopiedLabel.position.y += 25)

func _on_paste_button_pressed():
	if _copied_wave == null: 
		return
	
	var spawner = spawner_item_container.get_children()
	for i in _copied_wave.size():
		spawner[i].set_monsters_count_for_wave(_current_wave, _copied_wave[i])
		

func _update_ui():
	var spawners_exist = _spawner_settings_count > 0
	$NoSpawnerLabel.visible = not spawners_exist
	$CopyButton.visible = spawners_exist
	$PasteButton.visible = spawners_exist

#Takes this format
#   ---> MonsterWaveDTO of all spawners
# |
# |
# v Waves
func set_monster_waves(waves):
	_set_number_of_waves(waves.size())
	var idx = 0
	for wave in waves:
		for dto in wave:
			var spawner
			for item in spawner_item_container.get_children():
				if item.get_spawner_id() == dto.spawner_id:
					spawner = item
					item.set_monster_count_for_wave(idx, dto.monster_id, dto.count)
					break
		idx += 1

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
	_update_items_to_wave(wave)

func _on_wave_number_set_button_pressed():
	wave_number_info_label.visible = false
	var waves_text = wave_number_edit.text.strip_edges()
	if not util.is_str_valid_positive_int(waves_text):
		_show_wave_number_info_text("Invalid Input", false)
		wave_number_edit.text = str(_number_of_waves) #Reset to original value
		return
	
	var waves = waves_text as int
	if waves < GameplayConstants.MIN_NUMBER_OF_WAVES or waves > GameplayConstants.MAX_NUMBER_OF_WAVES:
		_show_wave_number_info_text(str("Must be in range ", GameplayConstants.MIN_NUMBER_OF_WAVES, " - ", GameplayConstants.MAX_NUMBER_OF_WAVES), false)
		wave_number_edit.text = str(_number_of_waves) #Reset to original value
		return

	if waves == _number_of_waves: #Value is already set
		return
		
	#Update waves
	_number_of_waves = waves
	_set_number_of_waves(_number_of_waves)
	
	if _current_wave >= waves: #If we edit wave 10 for example but now only have 5 anymore, set _current_wave to 5.
		_current_wave = waves - 1
		_set_current_wave(_current_wave)
	
	_show_wave_number_info_text(str("Wave Number set to ", _number_of_waves), true)

func _show_wave_number_info_text(text: String, success: bool):
	if success:
		wave_number_info_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		wave_number_info_label.add_theme_color_override("font_color", Color.RED)
	wave_number_info_label.text = text
	wave_number_info_label.visible = true

func update_spawner_waves():
	var waves = get_monster_waves()
	for spawner in GameState.gameState.spawners:
		spawner.waves.clear()
		for w in waves:
			var wave = []
			for v in w:
				if v.spawner_id == spawner.spawner_id:
					wave.append(v)
		
			spawner.waves.append(wave)
		spawner.initialise()
	Spawner.refresh_all_paths()

func open():
	$OpenCloseScaleAnimation.open()

func _on_close_button_pressed():
	update_spawner_waves()
	$OpenCloseScaleAnimation.close(hide)
