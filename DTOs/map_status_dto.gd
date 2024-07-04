extends BaseDTO
class_name MapStatusDTO

var map_name
var stars_unlocked

func _init(name="",unlocks=0):
	map_name=name
	stars_unlocked=unlocks
	pass;
