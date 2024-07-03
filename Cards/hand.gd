extends GameObject2D
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
	if children.is_empty():return;
	var off=clamp(800/get_child_count(),15,75)
	var offset=Vector2(75,0)
	children.reverse()
	var z_counter=get_child_count()*3;
	for c in children:
		c.z_index=z_counter
		c.originalZ=z_counter;
		z_counter=z_counter-3
		offset=offset+Vector2(off,0)
		var tween=create_tween()
		if tween!=null:tween.tween_property(c,"global_position",global_position+offset,0.5).set_ease(Tween.EASE_IN_OUT)
		c.originalPosition=global_position+offset
	pass;
func _on_button_pressed():
	
	drawCard()
	pass # Replace with function body.


func _on_menu_state_propagation(gamestate):
	state=gamestate;
	state.hand=self
	pass # Replace with function body.
