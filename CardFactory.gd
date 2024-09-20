extends Node2D
class_name CardFactory
static var instance=load("res://Cards/card_factory.tscn").instantiate()
@onready var default_preview=$DefaultPreview
static func get_card():
	var card=instance.get_node("BlockCard").duplicate()
	card.initialise()
	return card
	pass;
static func get_block_card(block):
	var card=instance.get_node("BlockCard").duplicate()
	card.initialise(block)
	card.visible=true;
	return card
static func get_special_Card(card_name):
	var card = instance.get_node(SpecialCardBase.Cardname.find_key(card_name)).duplicate()
	card.visible=true
	return card
	
	pass;
static func get_default_preview():
	if instance.default_preview==null:
		instance.default_preview=instance.get_node("DefaultPreview")
	var pr= instance.default_preview
	return pr
	pass;
