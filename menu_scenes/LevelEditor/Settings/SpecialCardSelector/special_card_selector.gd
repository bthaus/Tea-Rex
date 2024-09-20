extends Panel

@onready var all_container: GridContainer = $"TabContainer/All Cards/ScrollContainer/AllContainer"
@onready var blessed_container: GridContainer = $"TabContainer/Blessed Cards/ScrollContainer/BlessedContainer"
@onready var cursed_container: GridContainer = $"TabContainer/Cursed Cards/ScrollContainer/CursedContainer"

signal card_selected
signal canceled

func _ready():
	var card_names = SpecialCardBase.Cardname.keys()
	for i in card_names.size():
		var item = load("res://menu_scenes/LevelEditor/Settings/SpecialCardSelector/special_card_selector_item.tscn").instantiate()
		item.set_card(SpecialCardBase.Cardname.get(card_names[i]))
		item.clicked.connect(_on_item_clicked)
		all_container.add_child(item)

func _on_item_clicked(card: SpecialCardBase.Cardname):
	card_selected.emit(card)
	close()

func open():
	$OpenCloseScaleAnimation.open()

func close():
	$OpenCloseScaleAnimation.close(func(): queue_free)

func _on_cancel_button_pressed() -> void:
	canceled.emit()
	close()
