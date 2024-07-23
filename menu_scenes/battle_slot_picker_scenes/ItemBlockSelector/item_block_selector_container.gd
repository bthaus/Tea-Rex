extends Node2D

@onready var item_container = $Panel/ScrollContainer/ItemGridContainer


var _style_box: StyleBoxFlat = load("res://Styles/item_block_selector_tab.tres")
var _group: ButtonGroup

#Maps tab to values
@onready var _tab_map = [
	[$TargetingTab, Color.WHITE],
	[$ProjectileTab, Color.YELLOW],
	[$AmmunitionTab, Color.RED],
	[$HullTab, Color.ROYAL_BLUE],
	[$ProductionTab, Color.GREEN],
	[$KillEffectTab, Color.MAGENTA]
	]

func _ready():
	_group = $TargetingTab.button_group
	for i in _group.get_buttons():
		i.pressed.connect(func(): _select_tab(_group.get_pressed_button()))
	
	_init_tab_colors()
	_select_tab($TargetingTab)

func _select_tab(tab: Button):
	for t in _group.get_buttons():
		if t == tab: continue
		t.z_index = 0
		if t.position.y < $TabHeight.position.y:
			t.position.y = $TabHeight.position.y
	
	tab.position.y = $TabSelectedHeight.position.y
	tab.z_index = 1
	_update_container_color(tab)
	_update_container_items(tab)

func _update_container_items(tab):
	for child in item_container.get_children(): child.queue_free()
	for i in 10:
		var item = load("res://menu_scenes/battle_slot_picker_scenes/ItemBlockSelector/item_block_selector_item.tscn").instantiate()
		#TODO: insert actual item block
		item.clicked.connect(_on_item_clicked)
		item_container.add_child(item)

func _on_item_clicked(item_block: ItemBlockDTO):
	print(item_block)

func _init_tab_colors():
	for entry in _tab_map:
		var style = _style_box.duplicate()
		style.bg_color = entry[1]
		entry[0].add_theme_stylebox_override("normal", style)
		entry[0].add_theme_stylebox_override("hover", style)
		entry[0].add_theme_stylebox_override("pressed", style)
		entry[0].add_theme_stylebox_override("focus", style)
	
func _update_container_color(tab):
	var color
	for entry in _tab_map:
		if tab == entry[0]:
			color = entry[1]
			break
	
	var style = $Panel.get_theme_stylebox("panel")
	style.bg_color = color
	$Panel.add_theme_stylebox_override("panel", style)
