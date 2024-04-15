extends Node2D
@export var state:GameState;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func drawCard():
	var card=Card.create(state) as Button
	card.pressed.connect(card.get_child(0).select.bind( func(done:bool): if  done: card.queue_free() else: util.p("still in hand")))
	add_child(card)
	#add fancification here for initial animation

	pass; 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#add fancification here for reordering of cards on playing cards
	var children=get_children()
	var offset=Vector2(125,0)
	for c in children:
		offset=offset+Vector2(125,0)
		c.global_position=global_position+offset;
	pass


func _on_button_pressed():
	
	drawCard()
	pass # Replace with function body.
