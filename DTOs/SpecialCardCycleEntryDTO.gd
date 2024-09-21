extends BaseDTO
class_name SpecialCardCycleEntryDTO
var card_name
func _init(card_name:SpecialCardBase.Cardname = SpecialCardBase.Cardname.Fireball):
	self.card_name=card_name

func get_object():
	return card_name
	pass;

func get_card():
	return CardFactory.get_special_Card(get_object())
	pass;	
	
