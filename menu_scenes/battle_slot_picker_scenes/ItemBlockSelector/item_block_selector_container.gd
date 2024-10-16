extends Node2D

@onready var item_container = $Panel/ScrollContainer/ItemGridContainer


var _style_box: StyleBoxFlat = load("res://Styles/item_block_selector_tab.tres")
var _group: ButtonGroup
var _selected_tab: TabEntry = null
var _sandbox_mode = false
var _has_focus = false
signal item_selected

class TabEntry:
	var node
	var turret_mod_type: TurretBaseMod.ModType
	var display_color: Color
	func _init(node, turret_mod_type: TurretBaseMod.ModType, display_color: Color):
		self.node = node
		self.turret_mod_type = turret_mod_type
		self.display_color = display_color
		
#Maps tab to values
@onready var _tabs: Array[TabEntry] = [
	TabEntry.new($BaseTab, TurretBaseMod.ModType.BASE, Color.WHITE),
	TabEntry.new($ProjectileTab, TurretBaseMod.ModType.PROJECTILE, Color.YELLOW),
	TabEntry.new($AmmunitionTab, TurretBaseMod.ModType.AMMUNITION, Color.RED),
	TabEntry.new($HullTab, TurretBaseMod.ModType.HULL, Color.ROYAL_BLUE),
	TabEntry.new($ProductionTab, TurretBaseMod.ModType.PRODUCTION, Color.GREEN),
	TabEntry.new($KillEffectTab, TurretBaseMod.ModType.ONKILL, Color.MAGENTA)
	]

func _ready():
	_group = $BaseTab.button_group
	for i in _group.get_buttons():
		i.pressed.connect(func(): _select_tab(_group.get_pressed_button()))
	
	_init_tab_colors()
	_select_tab($BaseTab)

func _select_tab(tab: Button):
	for t in _group.get_buttons():
		if t == tab: continue
		t.z_index = 0
		if t.position.y < $TabHeight.position.y:
			t.position.y = $TabHeight.position.y
	
	tab.position.y = $TabSelectedHeight.position.y
	tab.z_index = 1
	for t in _tabs:
		if tab == t.node:
			_selected_tab = t
			break
	_update_container_color()
	update_container_items()

func update_container_items():
	var children = item_container.get_children()
	for child in children:
		item_container.remove_child(child)
		child.queue_free()
	
	#Gather all items that are currently in containers
	var items_in_use = []
	for container in Global.get_account().turret_mod_containers:
		for mod in container.turret_mods:
			items_in_use.append(mod.turret_mod)
	
	#Gather all items that are unlocked (if it is sandbox mode -> all), ignoring items that are already in use
	var items = []
	if _sandbox_mode:
		for mod_class in GameplayConstants.turret_mods.keys():
			var mod = mod_class.new()
			if mod.type == _selected_tab.turret_mod_type and not _contains_mod(items_in_use, mod):
				items.append(mod.get_item())
				
	elif Global.get_account() != null:
		for mod in Global.get_account().unlocked_turret_mods:
			if mod.type == _selected_tab.turret_mod_type and not _contains_mod(items_in_use, mod):
				items.append(mod.get_item())
	
	
	for item in items:
		var child = load("res://menu_scenes/battle_slot_picker_scenes/ItemBlockSelector/item_block_selector_item.tscn").instantiate()
		child.set_item(item)
		child.clicked.connect(_on_item_selected)
		item_container.add_child(child)

func _contains_mod(mod_array, mod: TurretBaseMod):
	for element in mod_array:
		if element.equals(mod):
			return true
	return false

func enable_sandbox_mode():
	_sandbox_mode = true
	update_container_items()

func _on_item_selected(item_block: ItemBlockDTO):
	item_selected.emit(item_block)
	update_container_items()

func _init_tab_colors():
	for entry in _tabs:
		var style = _style_box.duplicate()
		style.bg_color = entry.display_color
		entry.node.add_theme_stylebox_override("normal", style)
		entry.node.add_theme_stylebox_override("hover", style)
		entry.node.add_theme_stylebox_override("pressed", style)
		entry.node.add_theme_stylebox_override("focus", style)
	
func _update_container_color():
	var style = $Panel.get_theme_stylebox("panel")
	style.bg_color = _selected_tab.display_color
	$Panel.add_theme_stylebox_override("panel", style)

func has_focus() -> bool:
	return _has_focus

func _on_panel_mouse_entered() -> void:
	_has_focus = true

func _on_panel_mouse_exited() -> void:
	_has_focus = false
