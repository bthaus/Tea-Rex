extends Panel
class_name ItemPermutatorCardItem

@onready var block: Node2D = $Content/Block
@onready var card: Node = $Content/Card
@onready var block_preview: Node2D = $Content/Block/BlockPreview
@onready var card_preview: Label = $Content/Card/CardPreview

var _object: ItemPermutator.PermutationObject
var _parent: Control
var is_block_object: bool

signal input_enabled
signal duplicated

func set_object(object: ItemPermutator.PermutationObject):
	if not (object is BlockPermutationObject) and not (object is CardPermutationObject):
		util.p("Invaliv object present in permutator", "Jojo")
	_object = object
	is_block_object = object is BlockPermutationObject #BlockPermutationObject or CardPermutationObject
	if is_block_object:
		block.visible = true
		card.visible = false
		block_preview.set_block(object.block, false)
	else:
		block.visible = false
		card.visible = true
		#TODO: ADD ACTUAL CARD
		card_preview.text = util.format_name_string(SpecialCardBase.Cardname.keys()[object.card])

func show_object():
	$Content.visible = true

func hide_object():
	$Content.visible = false

func get_object() -> ItemPermutator.PermutationObject:
	return _object

func open_editor():
	input_enabled.emit(false)
	var editor = load("res://menu_scenes/LevelEditor/Settings/block_editor.tscn").instantiate()
	editor.set_block(_object.block)
	editor.saved.connect(_on_editor_saved)
	editor.canceled.connect(_on_editor_canceled)
	_parent.add_child(editor)
	editor.open()
	
func _on_editor_saved(block: Block):
	_object.block = block
	set_object(_object)
	input_enabled.emit(true)

func _on_editor_canceled():
	input_enabled.emit(true)

func open_card_selection():
	input_enabled.emit(false)
	var selection = load("res://menu_scenes/LevelEditor/Settings/CardSelector/card_selector.tscn").instantiate()
	selection.card_selected.connect(_on_card_selected)
	selection.canceled.connect(_on_card_selection_canceled)
	_parent.add_child(selection)
	selection.open()

func _on_card_selected(card: SpecialCardBase.Cardname):
	_object.card = card
	set_object(_object)
	input_enabled.emit(true)

func _on_card_selection_canceled():
	input_enabled.emit(true)

func enable_focus(enable: bool):
	var filter = MOUSE_FILTER_STOP if enable else MOUSE_FILTER_IGNORE
	$Content/EditButton.mouse_filter = filter
	$Content/DuplicateButton.mouse_filter = filter
	$Content/DeleteButton.mouse_filter = filter

func set_parent(parent: Control):
	_parent = parent

func _on_edit_button_pressed():
	if is_block_object:
		open_editor()
	else:
		open_card_selection()

func _on_duplicate_button_pressed():
	duplicated.emit(self)

func _on_delete_button_pressed():
	queue_free()
	
class BlockPermutationObject extends ItemPermutator.PermutationObject:
	var block: Block
	func _init(block: Block):
		self.block = block
	
	func clone() -> BlockPermutationObject:
		return BlockPermutationObject.new(block)

class CardPermutationObject extends ItemPermutator.PermutationObject:
	var card: SpecialCardBase.Cardname
	func _init(card: SpecialCardBase.Cardname):
		self.card = card
	
	func clone() -> CardPermutationObject:
		return CardPermutationObject.new(card)
