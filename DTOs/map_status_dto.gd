extends BaseDTO
class_name MapStatusDTO

var map_name
var stars_unlocked
var unlocked: bool

func _init(name = "", stars_unlocked = 0, unlocked: bool = false):
	self.map_name = name
	self.stars_unlocked = stars_unlocked
	self.unlocked = unlocked
