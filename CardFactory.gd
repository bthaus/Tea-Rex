extends Node2D
class_name CardFactory
static var instance=load("res://Cards/card_factory.tscn").instantiate()
static func get_card():
	var card=instance.get_node("BlockCard").duplicate()
	card.initialise()
	return card
	pass;
static func get_block_card(block):
	var card=instance.get_node("BlockCard").duplicate()
	card.initialise(block)
	return card
static func get_special_Card(card_name):
	return instance.get_node(SpecialCardBase.Cardname.find_key(card_name)).duplicate()
	pass;
