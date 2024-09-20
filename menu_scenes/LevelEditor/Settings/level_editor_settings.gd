extends Panel
class_name LevelEditorSettings

@onready var battle_slots = $ScrollContainer/VBoxContainer/BattleSlotsSettings
@onready var card_permutator = $ScrollContainer/VBoxContainer/CardPermutator
@onready var color_permutator = $ScrollContainer/VBoxContainer/ColorPermutator
@onready var tile_set = load("res://TileSets/game_board_tileset.tres")

@onready var card_item_path = "res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_card_item.tscn"
@onready var color_item_path = "res://menu_scenes/LevelEditor/Settings/ItemPermutator/item_permutator_color_item.tscn"
@onready var editor_path = "res://menu_scenes/LevelEditor/Settings/block_editor.tscn"
@onready var card_selector_path = "res://menu_scenes/LevelEditor/Settings/SpecialCardSelector/special_card_selector.tscn"

func _ready():
	$BlockCardSelector.block_selected.connect(_on_new_block_selected)
	$BlockCardSelector.custom_selected.connect(_on_custom_block_selected)
	
	#Init Block Permutator
	randomize()
	var blocks: Array[Block] = []
	for shape in Block.BlockShape.keys():
		blocks.append(BlockUtils.get_block_from_shape(Block.BlockShape.get(shape), Turret.Hue.WHITE))
	blocks.shuffle()
	_set_card_permutator(blocks)
	
	#Init Color Permutator
	randomize()
	var colors: Array[Turret.Hue] = []
	for hue in Turret.Hue.keys():
		colors.append(Turret.Hue.get(hue))
	colors.shuffle()
	_set_color_permutator(colors)

func _set_card_permutator(blocks: Array[Block]):
	var block_objects: Array[ItemPermutator.PermutationObject] = []
	for block in blocks:
		block_objects.append(ItemPermutatorCardItem.BlockPermutationObject.new(block))
	card_permutator.set_objects(card_item_path, block_objects)
	card_permutator.append_object(card_item_path, ItemPermutatorCardItem.CardPermutationObject.new(SpecialCardBase.Cardname.Fireball))

func _set_color_permutator(colors: Array[Turret.Hue]):
	var color_objects: Array[ItemPermutator.PermutationObject] = []
	for color in colors:
		color_objects.append(ItemPermutatorColorItem.ColorPermutationObject.new(color, _color_to_texture(color)))
	color_permutator.set_objects(color_item_path, color_objects)

func load_settings(map_dto: MapDTO):
	battle_slots.load_settings(map_dto.battle_slots)
	var blocks: Array[Block] = []
	for block in map_dto.card_cycle:
		blocks.append(block.get_object())
	_set_card_permutator(blocks)
	
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
	$BlockCardSelector.open()

func _on_add_card_button_pressed():
	var selector = load(card_selector_path).instantiate()
	add_child(selector)
	selector.card_selected.connect(_on_new_card_selected)
	selector.open()
	
func _on_new_card_selected(card: SpecialCardBase.Cardname):
	var object = ItemPermutatorCardItem.CardPermutationObject.new(card)
	card_permutator.append_object(card_item_path, object)

func _on_new_block_selected(block: Block):
	var object = ItemPermutatorCardItem.BlockPermutationObject.new(block)
	card_permutator.append_object(card_item_path, object)

func _on_custom_block_selected():
	var editor = load(editor_path).instantiate()
	add_child(editor)
	editor.set_block(Block.new([]))
	editor.saved.connect(_on_block_editor_saved)
	editor.open()

func _on_block_editor_saved(sender, block: Block):
	var object = ItemPermutatorCardItem.BlockPermutationObject.new(block)
	card_permutator.append_object(card_item_path, object)
	$BlockCardSelector.close()

func open():
	$OpenCloseScaleAnimation.open()

func _on_close_button_pressed():
	$OpenCloseScaleAnimation.close(hide)

func get_setting_properties() -> Properties:
	var settings = Properties.new()
	settings.battle_slots_amount = battle_slots.get_amount()
	settings.card_cycle = get_card_cycle()
	settings.color_cycle = get_color_cycle()
	return settings

func get_card_cycle() -> Array[BaseDTO]:
	var objects = card_permutator.get_objects()
	var card_cycle: Array[BaseDTO] = []
	for obj in objects:
		var positions = []
		for piece in obj.value.pieces:
			positions.append({"x": piece.position.x, "y": piece.position.y})
		card_cycle.append(BlockCycleEntryDTO.new(positions))
	return card_cycle

func get_color_cycle() -> Array:
	var objects = color_permutator.get_objects()
	var color_cycle = []
	for obj in objects:
		color_cycle.append(obj.value)
	return color_cycle

class Properties:
	var battle_slots_amount: int
	var card_cycle: Array
	var color_cycle: Array
