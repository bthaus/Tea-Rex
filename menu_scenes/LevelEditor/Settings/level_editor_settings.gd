extends Panel

@onready var block_permutator = $ScrollContainer/VBoxContainer/BlockPermutator
@onready var color_permutator = $ScrollContainer/VBoxContainer/ColorPermutator

func _ready():
	#Init Block Permutator
	randomize()
	var block_objects: Array[ItemPermutator.PermutationObject] = []
	for shape in Block.BlockShape.keys():
		var block = BlockUtils.get_block_from_shape(Block.BlockShape.get(shape), Turret.Hue.WHITE)
		block_objects.append(ItemPermutator.PermutationObject.new(block, null))
	block_objects.shuffle()
	block_permutator.set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_block_item.tscn", block_objects)
	
	#Init Color Permutator
	randomize()
	var color_objects: Array[ItemPermutator.PermutationObject] = []
	for color in Turret.Hue.keys():
		color_objects.append(ItemPermutator.PermutationObject.new(Turret.Hue.get(color), null))
	color_objects.shuffle()
	color_permutator.set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_sprite_item.tscn", color_objects)
