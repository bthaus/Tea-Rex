extends Panel

@onready var monster_item_container = $MonsterScrollContainer/MonsterItemContainer

var _spawner_id: int
var _number_of_waves = 0
var _current_wave = 0

signal copy
signal paste

func get_spawner_id() -> int:
	return _spawner_id

func set_spawner_id(id: int):
	_spawner_id = id
	$SpawnerId.text = str(id + 1)
	
func _ready():
	for i in 8: #Replace with actual number of minions
		var item = load("res://LevelEditor/ContainerItems/monster_setting_item.tscn").instantiate()
		monster_item_container.add_child(item)
		item.set_monster_id(i)
		
func update_items(wave: int):
	_current_wave = wave
	for item in monster_item_container.get_children():
		item.update(wave)

func set_number_of_waves(amount: int):
	_number_of_waves = amount
	for item in monster_item_container.get_children():
		item.set_number_of_waves(amount)

#Returns this format, for ONE spawner
#   ---> MonsterWaveDTO
# |
# |
# v Waves
func get_spawner():
	var waves = []
	waves.resize(_number_of_waves)
	for i in waves.size(): waves[i] = []
	
	for item in monster_item_container.get_children():
		var i = 0
		for amount in item.get_monsters():
			waves[i].append(MonsterWaveDTO.new(_spawner_id, item.get_monster_id(), amount))
			i+=1
			
	return waves

func set_monsters_for_wave(wave: int, monsters: Array):
	var idx = 0
	for item in monster_item_container.get_children():
		item.set_monster_count_for_wave(wave, monsters[idx])
		item.update(wave)
		idx += 1

func _on_copy_button_pressed():
	var monster_counts = []
	for item in monster_item_container.get_children():
		var monsters = item.get_monsters()[_current_wave]
		monster_counts.append(monsters)
	
	copy.emit(monster_counts)

func _on_paste_button_pressed():
	paste.emit(self)
