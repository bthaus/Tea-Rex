extends Node2D
class_name Card
var card;
var state:GameState;
var description:String;
static var isCardSelected=false;
static var selectedCard;
signal mouseIn
signal mouseOut

func select(done:Callable):
	if isCardSelected&&selectedCard!=self:
		
		if (selectedCard.card!=null)&&(selectedCard.card is BlockCard):
			state.gameBoard._action_finished(false)
			selectedCard=self;
		elif (selectedCard.card!=null)&&(selectedCard.card is SpecialCard):
			selectedCard.card.interrupt()
			selectedCard=self;	
		
	if self is BlockCard and state.phase!=Stats.GamePhase.BUILD:
		return;
		
	
	isCardSelected=true;
	selectedCard=self;
	scale=Vector2(1.3,1.3)
	
	z_index=10
	card.select(done)
	
	pass;
static var counter=0;
signal finished(card)

func setCard(c):
	card=c;
	add_child(c)
	pass;
static func create(gameState:GameState,card=-1):
	counter=counter+1;
	var c=load("res://card.tscn").instantiate() as Card
	
	
	var btn=c.get_child(0) as Button
	if card is Card:
		c.setCard(card)
	else:	
		c.setCard(Stats.getRandomCard(gameState))
	c.state=gameState;

	if c.card is SpecialCard:
		c.get_child(1).text=Stats.getStringFromSpecialCardEnum(c.card.cardName);
		c.get_child(1).visible=true;
		var cardname=c.card.cardName;
		c.get_node("Button").icon=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardname)+"_preview.png")
		c.description=Stats.getDescription(Stats.getStringFromSpecialCardEnum(cardname))
	if c.card is BlockCard:
		
		
		var extension=c.card.block.extension;
		var color=c.card.block.color;
		c.get_node("Button").icon=load("res://Assets/Cards/Testcard_"+Stats.getStringFromEnum(color).to_lower()+".png")
		#use this to change color/text of card
		var preview=load("res://Cards/block_preview.tscn").instantiate()
		if extension!=1: c.description=Stats.getDescription(Stats.TurretExtension.keys()[extension-1])
		else: c.description=Stats.getDescription(Stats.getStringFromEnum(color))
		preview.set_block(c.card.block, true)
		preview.scale=Vector2(0.3,0.3)
		preview.position=Vector2(50,100)
		btn.add_child(preview)
	
	return c
	
func played(interrupted:bool):
	scale=Vector2(1,1)
	z_index=0
			
	isCardSelected=false;
	if  interrupted:
		queue_free()
		finished.emit(self)
		get_tree().create_timer(0.5).timeout.connect(GameSaver.saveGame.bind(state))
		
	pass;
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	originalPosition=global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	select(played)
	pass # Replace with function body.

var originalPosition;
func _on_button_mouse_entered():
	z_index=10
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition+Vector2(0, -25), 0.5)
	state.menu.showDescription(description)
	
	pass # Replace with function body.


func _on_button_mouse_exited():
	z_index=0
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition, 0.5)
	state.menu.hideDescription()
	mouseOut.emit()
	pass # Replace with function body.
