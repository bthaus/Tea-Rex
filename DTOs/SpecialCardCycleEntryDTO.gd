extends BaseDTO
class_name SpecialCardCycleEntryDTO
var card_name
func _init(card_name:SpecialCardBase.Cardname):
	self.card_name=card_name

func get_object():
	return CardFactory.get_special_Card(card_name);
	pass;
	
	
