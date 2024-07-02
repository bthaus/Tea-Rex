extends Panel

@onready var minion_item_container = $MinionScrollContainer/MinionItemContainer

var _spawner_id: int

func get_spawner_id() -> int:
	return _spawner_id

func set_spawner_id(id: int):
	_spawner_id = id
	$SpawnerId.text = str(id)
	
func _ready():
	for i in 8: #Replace with actual number of minions
		var item = load("res://LevelEditor/ContainerItems/minion_setting_item.tscn").instantiate()
		minion_item_container.add_child(item)
