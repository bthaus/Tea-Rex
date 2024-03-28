extends Node2D
class_name SpecialCard

@export var cardName:Stats.SpecialCards;
@onready var gameState=get_node("/root/State") as GameState;
var selected=false;
var damage;
var range;
var done:Callable;
var instant=false;
var roundsInHand=1;
var roundReceived:int;
var maxroundsHeld=1;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Preview.texture=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardName)+"_preview.png")
	roundReceived=gameState.wave;
	range=Stats.getCardRange(cardName);
	damage=Stats.getCardDamage(cardName);
	maxroundsHeld=Stats.getMaxRoundsHeld(cardName)
	instant=Stats.getCardInstant(cardName)
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
	self.done=done;
	selected=true;
	
	if instant:
		cast()
		return;
	$Preview.visible=true;
	pass;

func cast():
	call("cast"+Stats.getStringFromSpecialCardEnum(cardName))
	$EffectSound.play();
	done.call(true)
	pass;
	

func castHEAL():
	checkRoundMultiplicator()
	damage=damage*roundsInHand*range;
	gameState.changeHealth(damage);
	pass;

func castFIREBALL():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	for e in $Effect/EnemyDetector.enemiesInRange:
		e.hit(Stats.TurretColor.GREY,damage)
	pass;	
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
	if Input.is_action_just_pressed("right_click"):
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
	

	
