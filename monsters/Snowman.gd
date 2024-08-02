extends MonsterCore
class_name SnowmanCore
@export var range=1



# Called when the node enters the scene tree for the first time.
func on_death():
	FrostExplosion.create(null,0,global_position,self)
	super()
	pass;
