extends Panel
class_name LevelEditorSettings

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

func _on_close_button_pressed():
	hide()

func get_setting_properties() -> Properties:
	var settings = Properties.new()
	settings.block_cycle = get_block_cycle()
	settings.color_cycle = get_color_cycle()
	return settings

func get_block_cycle() -> Array[BaseDTO]:
	var objects = block_permutator.get_objects()
	var block_cycle: Array[BaseDTO] = []
	for obj in objects:
		var positions = []
		for piece in obj.value.pieces:
			positions.append({"x": piece.position.x, "y": piece.position.y})
		block_cycle.append(BlockCycleEntryDTO.new(positions))
	return block_cycle

func get_color_cycle() -> Array:
	var objects = color_permutator.get_objects()
	var color_cycle = []
	for obj in objects:
		color_cycle.append(obj.value)
	return color_cycle

class Properties:
	var block_cycle: Array
	var color_cycle: Array
