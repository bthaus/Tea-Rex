extends Panel
class_name LevelEditorSettings

@onready var block_permutator = $ScrollContainer/VBoxContainer/BlockPermutator
@onready var color_permutator = $ScrollContainer/VBoxContainer/ColorPermutator
@onready var tile_set = load("res://TileSets/game_board_tileset.tres")

func _ready():
	#Init Block Permutator
	randomize()
	var blocks: Array[Block] = []
	for shape in Block.BlockShape.keys():
		blocks.append(BlockUtils.get_block_from_shape(Block.BlockShape.get(shape), Turret.Hue.WHITE))
	blocks.shuffle()
	_set_block_permutator(blocks)
	
	#Init Color Permutator
	randomize()
	var colors: Array[Turret.Hue] = []
	for hue in Turret.Hue.keys():
		colors.append(Turret.Hue.get(hue))
	colors.shuffle()
	_set_color_permutator(colors)

func _set_block_permutator(blocks: Array[Block]):
	var block_objects: Array[ItemPermutator.PermutationObject] = []
	for block in blocks:
		block_objects.append(ItemPermutator.PermutationObject.new(block, null))
	block_permutator.set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_block_item.tscn", block_objects)

func _set_color_permutator(colors: Array[Turret.Hue]):
	var color_objects: Array[ItemPermutator.PermutationObject] = []
	for color in colors:
		color_objects.append(ItemPermutator.PermutationObject.new(color, _color_to_texture(color)))
	color_permutator.set_objects("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_sprite_item.tscn", color_objects)

func load_settings(map_dto: MapDTO):
	var blocks: Array[Block] = []
	for block in map_dto.block_cycle:
		blocks.append(block.get_object())
	_set_block_permutator(blocks)
	
	var colors: Array[Turret.Hue] = []
	for color in map_dto.color_cycle:
		colors.append(Turret.Hue.get(Turret.Hue.keys()[color-1]))
	_set_color_permutator(colors)

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
	

func _on_add_block_button_pressed():
	var block_selector = load("res://menu_scenes/LevelEditor/Settings/BlockSelector/block_selector.tscn").instantiate()
	block_selector.block_selected.connect(_on_new_block_selected)
	block_selector.custom_selected.connect(_on_custom_block_selected)
	add_child(block_selector)
	
func _on_new_block_selected(block: Block):
	var object = ItemPermutator.PermutationObject.new(block, null)
	block_permutator.add_object("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_block_item.tscn", object)

func _on_custom_block_selected():
	var object = ItemPermutator.PermutationObject.new(Block.new([]), null)
	block_permutator.add_object("res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_block_item.tscn", object)
	var item = block_permutator.get_item_node(block_permutator.get_objects().size()-1)
	item.open_editor()

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
