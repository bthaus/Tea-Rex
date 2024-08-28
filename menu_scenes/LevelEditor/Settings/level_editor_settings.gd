extends Panel
class_name LevelEditorSettings

@onready var block_permutator = $ScrollContainer/VBoxContainer/BlockPermutator
@onready var color_permutator = $ScrollContainer/VBoxContainer/ColorPermutator
@onready var tile_set = load("res://TileSets/game_board_tileset.tres")

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
		var c = Turret.Hue.get(color)
		color_objects.append(ItemPermutator.PermutationObject.new(c, _color_to_texture(c)))
	color_objects.shuffle()
	color_permutator.set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_sprite_item.tscn", color_objects)

func load_settings():
	pass

func _color_to_texture(color: Turret.Hue) -> Texture2D:
	var id: int
	match (color):
		Turret.Hue.WHITE: id = 101
		Turret.Hue.GREEN: id = 201
		Turret.Hue.RED: id = 301
		Turret.Hue.YELLOW: id = 401
		Turret.Hue.BLUE: id = 501
		Turret.Hue.MAGENTA: id = 601
	var atlas: TileSetAtlasSource = tile_set.get_source(id)
	return atlas.texture

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
