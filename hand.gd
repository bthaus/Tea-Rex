extends Node2D
@export var state:GameState;
@export var description:Label
# Called when the node enters the scene tree for the first time.
func _ready():
	child_order_changed.connect(reorder)
	pass # Replace with function body.

func drawCard(card:Card=null):
	if state.maxCards<=get_children().size(): return
	if card==null:
		card=Card.create(state)
	card.get_node("Button").mouse_entered.connect(func():print(card.description))
	#card.mouseOut.connect(func():print("hii");description.text=" ")
	add_child(card)
	#add fancification here for initial animation
	GameSaver.saveGame(state)
	pass; 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#add fancification here for reordering of cards on playing cards
	
	pass

func reorder():
	var children=get_children()
	var offset=Vector2(125,0)
	for c in children:
		offset=offset+Vector2(125,0)
		c.global_position=global_position+offset;
	pass;
func _on_button_pressed():
	
	drawCard()
	pass # Replace with function body.


func _on_menu_state_propagation(gamestate):
	state=gamestate;
	state.hand=self
	pass # Replace with function body.
