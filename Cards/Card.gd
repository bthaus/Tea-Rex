extends GameObject2D
class_name Card
var card;
var state:GameState;
var description:String;
static var isCardSelected=false;
static var selectedCard;
signal mouseIn
signal mouseOut

func select(done:Callable):
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY).timeout.connect(delayedSelect.bind(done))
	pass;
func delayedSelect(done):
	if isCardSelected&&selectedCard!=self:
		
		if (selectedCard.card!=null)&&(selectedCard.card is BlockCard):
			state.gameBoard._action_finished(false)
			selectedCard=self;
		#elif (selectedCard.card!=null)&&(selectedCard.card is SpecialCard):
			#selectedCard.card.interrupt()
			#selectedCard=self;	
	
	if self is BlockCard and state.phase!=GameState.GamePhase.BUILD:
		return;
	$DisableButton/DisableCard.show()
	$DisableButton.mouse_filter=0;
	$Button.mouse_filter=2;	
	
	isCardSelected=true;
	selectedCard=self;
	scale=Vector2(1.3,1.3)
	
	z_index=2000
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
	var c=load("res://Cards/card.tscn").instantiate() as Card
	
	
	var btn=c.get_child(0) as Button
	if card is Card:
		c.setCard(card)
	else:	
		c.setCard(BlockCard.create(gameState))
	c.state=gameState;

	#if c.card is SpecialCard:
		##enum SpecialCards {HEAL=1,FIREBALL=2,UPHEALTH=3,CRYOBALL=4,MOVE=5, BULLDOZER=6,GLUE=7,POISON=8, UPDRAW=9, UPMAXCARDS=10}
		#var label=""
		#gameState.start_build_phase.connect(func():
			#if c==null:return
			#match c.card.cardName:
				#1:c.description=	"Heals "+str(c.card.getHealAmount())+" HP. The longer you hold it, the more it heals. "
				#2:label="Deals "+str(c.card.damage)+" damage."
				#3:c.description=	"Gives "+str(c.card.getHealAmount())+" HP. The longer you hold it, the more it gives you."
				#4:label="Deals "+str(c.card.damage)+" damage."
				#6:label="Removes "+str(c.card.damage)+"x"+str(c.card.range)+" blocks."
				#5:label="Moves 1 block"
				#7:label="Slows enemies"
				#8:label="Poisons for "+str(c.card.damage)+"."
				#9:label="Draw 1 card more."
				#10:label="Handsize +1."
			#
			#c.get_child(1).text=""	
					#)
		#match c.card.cardName:
			#1:c.description=	"Heals "+str(c.card.getHealAmount())+" HP. The longer you hold it, the more it heals. "
			#2:label="Deals "+str(c.card.damage)+" damage."
			#3:c.description=	"Gives "+str(c.card.getHealAmount())+" HP. The longer you hold it, the more it gives you."
			#4:label="Deals "+str(c.card.damage)+" damage."
			#6:label="Removes "+str(c.card.damage)+"x"+str(c.card.range)+" blocks."
			#5:label="Moves 1 block"
			#7:label="Slows enemies"
			#8:label="Poisons for "+str(c.card.damage)+"."
			#9:label="Draw 1 card more."
			#10:label="Handsize +1."
			#
		#c.get_child(1).text=""
		#c.get_child(1).visible=true;
		#var cardname=c.card.cardName;
		#c.get_node("Button").icon=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardname)+"_preview.png")
		#if c.description=="":
			#c.description=Stats.getDescription(Stats.getStringFromSpecialCardEnum(cardname))
	if c.card is BlockCard:
		
		
		var extension=c.card.block.extension;
		var color=c.card.block.color;
		#if extension==1:
		#	c.get_node("Label").text=Stats.getName(Turret.Hue.find_key(color))
		#else:
		#	c.get_node("Label").text=Stats.getName(Turret.Extension.find_key(extension))	
		c.get_node("Label").text=""
		var ic=load("res://Assets/Cards/Testcard_"+util.getStringFromEnum(color).to_lower()+".png")
		if ic==null:
			ic=load("res://Assets/Cards/Testcard_white.png")
		c.get_node("Button").icon=ic	#use this to change color/text of card
		c.preview=load("res://Cards/block_preview.tscn").instantiate()
		c.preview.set_block(c.card.block, true)
		c.preview.position=Vector2(50,100)
		c.preview.scale=Vector2(0.3,0.3)
		btn.add_child(c.preview)
	
	return c
var preview	
func played(interrupted:bool):
	
	if  interrupted:
		if card is BlockCard:
			preview.clear_preview();
			preview.queue_free()
		queue_free()
		finished.emit(self)
	if isCardSelected:
		_on_disable_button_pressed()	
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
var originalZ=0;
func _on_button_mouse_entered():
	originalZ=z_index;
	z_index=2000
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition+Vector2(0, -25), 0.5)
	state.ui.showDescription(description)
	
	pass # Replace with function body.


func _on_button_mouse_exited():
	if selectedCard!=self:
		z_index=originalZ
	var tween = create_tween()
	tween.tween_property(self, "global_position", originalPosition, 0.5)
	state.ui.hideDescription()
	mouseOut.emit()
	pass # Replace with function body.


func _on_disable_button_pressed():
	scale=Vector2(1,1)
	z_index=originalZ
	get_tree().create_timer(GameplayConstants.CARD_PLACEMENT_DELAY+0.1).timeout.connect(func():$Button.mouse_filter=0)
	$DisableButton.mouse_filter=2
	$DisableButton/DisableCard.hide()
	isCardSelected=false;	
	GameState.gameState.gameBoard.action=GameBoard.BoardAction.NONE
	if (selectedCard.card!=null)&&(selectedCard.card is BlockCard):
			state.gameBoard._action_finished(false)
			selectedCard=null;
	#elif (selectedCard.card!=null)&&(selectedCard.card is SpecialCard):
			#selectedCard.card.interrupt()
			#selectedCard=null;	
	
	pass # Replace with function body.

static var contemplatingInterrupt=false;
static var hoveredCard=null
func _on_disable_button_mouse_entered():
	hoveredCard=self
	contemplatingInterrupt=true;
	
	pass # Replace with function body.


func _on_disable_button_mouse_exited():
	if hoveredCard==self:
		hoveredCard==null;
		contemplatingInterrupt=false;	
			
		
	if hoveredCard==null:
		contemplatingInterrupt=false;	
	
		
	pass # Replace with function body.
