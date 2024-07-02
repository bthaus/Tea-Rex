extends Panel

@onready var monster_item_container = $MonsterScrollContainer/MonsterItemContainer

var _spawner_id: int

func get_spawner_id() -> int:
	return _spawner_id

func set_spawner_id(id: int):
	_spawner_id = id
	$SpawnerId.text = str(id)
	
func _ready():
	for i in 8: #Replace with actual number of minions
		var item = load("res://LevelEditor/ContainerItems/monster_setting_item.tscn").instantiate()
		monster_item_container.add_child(item)
		
func update_items(wave: int):
	for item in monster_item_container.get_children():
		item.update(wave)
