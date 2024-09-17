extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add("sim_debug",FireAmmunitionMod.new())
	pass # Replace with function body.

func add(mapname,item):
	TreasureDTO.add_treasure_to_map(mapname,item)
	pass;
