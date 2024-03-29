extends Node2D
class_name SpecialCard

@export var cardName:Stats.SpecialCards;
#subject to change
@onready var gameState=get_parent() as GameState;

var selected=false;
var damage;
var range;
var done:Callable;
var instant=false;
var roundsInHand=1;
var roundReceived:int;
var maxroundsHeld=1;
var phase:Stats.GamePhase

# Called when the node enters the scene tree for the first time.
func _ready():
	
	util.p("gamestate for cards is still maldefined, please check once main scene is set up","Bodo","FutureFix")

	
	var text=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardName)+"_preview.png")
	
	if text!=null:
		$Preview.texture=text
	
	roundReceived=gameState.wave;
	range=Stats.getCardRange(cardName);
	damage=Stats.getCardDamage(cardName);
	maxroundsHeld=Stats.getMaxRoundsHeld(cardName)
	instant=Stats.getCardInstant(cardName)
	phase=Stats.getCardPhase(cardName)
	
	if range!=null:
		$Effect.apply_scale(Vector2(range,range));
		$Effect/EnemyDetector.apply_scale(Vector2(range,range))
	
	
	$EffectSound.stream=load("res://Sounds/Soundeffects/"+Stats.getStringFromSpecialCardEnum(cardName)+"_sound.wav");
	pass # Replace with function body.
#just pass the method name, like "card.select(cast)". first parameter is a boolean. true for successfully played card, false for not played card
static func create(cardname:Stats.SpecialCards)->SpecialCard:
	var retval=load("res://special_card.tscn").instantiate() as SpecialCard;
	retval.cardName=cardname;
	return retval
	
func select(done:Callable):
	if !isPhaseValid():
		done.call(false)
		return
	self.done=done;
	
	
	if instant:
		cast()
		return;
		
	selected=true;
	$Preview.visible=true;
	pass;

func cast():
	if call("cast"+Stats.getStringFromSpecialCardEnum(cardName)):
		done.call(true)
	$EffectSound.play();
	
	pass;

func castBULLDOZER()->bool:
	gameState.gameBoard.start_bulldozer(done,damage,range);
	return false;	
func castMOVE()->bool:
	gameState.gameBoard.start_move(done);
	return false;	

func castHEAL():
	checkRoundMultiplicator()
	damage=damage*roundsInHand*range;
	gameState.changeHealth(damage);
	return true;

func castUPHEALTH():
	checkRoundMultiplicator()
	damage=damage*roundsInHand*range;
	gameState.changeMaxHealth(damage);
	return true;

func castFIREBALL():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	for e in $Effect/EnemyDetector.enemiesInRange:
		e.hit(Stats.TurretColor.GREY,damage)
	return true;

func castCRYOBALL():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	for e in $Effect/EnemyDetector.enemiesInRange:
		e.hit(Stats.TurretColor.GREY,damage)
		e.add_child(Slower.create(Stats.CRYOBALL_slowDuration,Stats.CRYOBALL_slowFactor))
	return true;
	
func _input(event):
	if !selected:
		return;
	
	if event.is_action_pressed("left_click"):
		selected=false;
		$Preview.visible=false;
		cast()
	pass;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interrupt"):
		selected=false;
		done.call(false)
		$Preview.visible=false;
		
	if Input.is_action_just_pressed("save"):
		select(testcall)
	
	if selected:
		$Preview.global_position=get_global_mouse_position();
		$Effect.global_position=get_global_mouse_position();
	pass

func testcall(returned):
	print(returned)
	pass;
func _on_effect_animation_finished():
	$Effect.visible=false;
	pass # Replace with function body.
	
func checkRoundMultiplicator():
		roundsInHand=gameState.wave-roundReceived;
	
		if roundsInHand>maxroundsHeld:
			roundsInHand=maxroundsHeld;
		
		if roundsInHand<=1:
			roundsInHand=1;
		pass;

func isPhaseValid()->bool:
	return gameState.phase==phase||phase==Stats.GamePhase.BOTH||gameState.phase==Stats.GamePhase.BOTH
	
	

	
