extends Node2D

var style_box: StyleBoxFlat = load("res://Styles/item_block_selector_tab.tres")
var group: ButtonGroup

func _ready():
	group = $TargetingTab.button_group
	_change_tab_color($TargetingTab, Color.WHITE)
	_change_tab_color($ProjectileTab, Color.YELLOW)
	_change_tab_color($AmmunitionTab, Color.RED)
	_change_tab_color($HullTab, Color.ROYAL_BLUE)
	_change_tab_color($ProductionTab, Color.GREEN)
	_change_tab_color($KillEffectTab, Color.MAGENTA)
	
	for i in group.get_buttons():
		i.pressed.connect(_tab_pressed)
		

func _tab_pressed():
	var tab = group.get_pressed_button()
	for t in group.get_buttons():
		if t == tab: continue
		if t.position.y < $TabHeight.position.y:
			t.position.y = $TabHeight.position.y
	
	tab.position.y = $TabSelectedHeight.position.y

func _change_tab_color(node, color: Color):
	var style = style_box.duplicate()
	style.bg_color = color
	node.add_theme_stylebox_override("normal", style)
	node.add_theme_stylebox_override("hover", style)
	node.add_theme_stylebox_override("pressed", style)
	node.add_theme_stylebox_override("focus", style)
