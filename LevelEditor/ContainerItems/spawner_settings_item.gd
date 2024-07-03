extends Panel

@onready var monster_item_container = $MonsterScrollContainer/MonsterItemContainer

var _spawner_id: int
var _number_of_waves = 0

func get_spawner_id() -> int:
	return _spawner_id

func set_spawner_id(id: int):
	_spawner_id = id
	$SpawnerId.text = str(id)
	
func _ready():
	for i in 8: #Replace with actual number of minions
		var item = load("res://LevelEditor/ContainerItems/monster_setting_item.tscn").instantiate()
		monster_item_container.add_child(item)
		item.set_monster_id(i)
		
func update_items(wave: int):
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
