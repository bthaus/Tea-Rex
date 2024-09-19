extends Node2D
class_name CardFactory
static var instance=load("res://Cards/card_factory.tscn").instantiate()
static func get_card():
	var card=instance.get_node("BlockCard").duplicate()
	card.initialise()
	return card
	pass;
