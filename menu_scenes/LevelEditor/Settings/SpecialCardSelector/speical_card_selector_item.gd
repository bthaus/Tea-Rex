extends Button

var card: SpecialCardBase.Cardname
signal clicked

func set_card(card: SpecialCardBase.Cardname):
	self.card = card
	$Label.text = util.format_name_string(SpecialCardBase.Cardname.keys()[card])

func _on_pressed() -> void:
	clicked.emit(card)
