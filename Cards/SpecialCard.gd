extends Card
class_name SpecialCard

var cardName:Stats.SpecialCards;
#subject to change
var gameState;

var selected=false;
var damage;
var range;
var done:Callable;
var instant=false;
var roundsInHand=1;
var roundReceived:int;
var maxroundsHeld=1;
var phase:Stats.GamePhase
var active=false;
var tasks=[]
static var cardID=0;
var ID;
static var rng=RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	util.p("gamestate for cards is still maldefined, please check once main scene is set up","Bodo","FutureFix")

	
	var text=load("res://Assets/SpecialCards/"+Stats.getStringFromSpecialCardEnum(cardName)+"_preview.png")
	
	if text==null:
		text=load("res://Assets/SpecialCards/DEFAULT_preview.png")
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
static func create(gameState:GameState):

	var retval=load("res://special_card.tscn").instantiate() as SpecialCard;
	retval.ID=cardID+1;
	var rand=rng.randi_range(0,Stats.SpecialCards.keys().size()-1)

	retval.cardName=rand;
	retval.gameState=gameState

	
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
	reparentToState()
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
func castUPDRAW():
	gameState.upRedraws()
	return true;
	
	
func castUPMAXCARDS():
	gameState.upMaxCards()
	return true;	
	
func castFIREBALL():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	$Effect/EnemyDetector.enemyEntered.connect(func(e):
		print("enemy hit")
		e.hit(Stats.TurretColor.GREY,damage))
	return true;

func castCRYOBALL():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	$Effect/EnemyDetector.enemyEntered.connect(func(e):
		e.hit(Stats.TurretColor.GREY,damage)
		e.add_child(Slower.create(Stats.CRYOBALL_slowDuration,Stats.CRYOBALL_slowFactor)))

	return true;

func castGLUE():

	$Effect.play("GLUE")
	$Effect.visible=true;
	$Effect.z_index=-1
	active=true;
	$Effect.global_position=get_global_mouse_position();
	var removeGlue=func removeGLUE(monster:Monster):
		for a in monster.get_children():
			if a is Slower:
				if a.ID==ID:
					a.remove()
		pass;
	var addGlue=func addGLUE(monster:Monster):
			if !active:
				return
			var slower=Slower.create(Stats.GLUE_Duration,Stats.GLUE_slowFactor)	
			$Effect/EnemyDetector.enemyLeft.connect(func(e): if e==monster:slower.remove())
			monster.add_child(slower)
				
			pass;
	
	for m in $Effect/EnemyDetector.enemiesInRange:
		addGlue.call(m)
	
	$Effect/EnemyDetector.enemyEntered.connect(addGlue)
	#$Effect/EnemyDetector.enemyLeft.connect(removeGlue)
	get_tree().create_timer(Stats.GLUE_Duration-0.5).timeout.connect(func removeAllGLUE():
		$Effect.visible=false;
		for m in $Effect/EnemyDetector.enemiesInRange:
			removeGlue.call(m)
		active=false;
		queue_free()
		pass;)
		
	return true;
func castPOISON():
	$Effect.visible=true;
	$Effect.global_position=get_global_mouse_position();
	$Effect.play(Stats.getStringFromSpecialCardEnum(cardName));
	$Effect/EnemyDetector.enemyEntered.connect(func(e):e.add_child(Poison.create(damage,Stats.POISON_decay)))
		
		
	return true;
	pass;	
func reparentToState():
	get_parent().remove_child(self)
	gameState.add_child(self)
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
	if active:
		for t in tasks:
			t.call()
	
	if Input.is_action_just_pressed("interrupt")&&selected:
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
	queue_free()
	#done.call(true)
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
	
	

	



