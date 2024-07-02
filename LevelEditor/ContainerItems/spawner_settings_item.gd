extends Panel

@onready var minion_item_container = $MinionScrollContainer/MinionItemContainer

func _ready():
	for i in 8:
		var item = load("res://LevelEditor/ContainerItems/minion_setting_item.tscn").instantiate()
		minion_item_container.add_child(item)
