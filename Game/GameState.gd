extends Node2D
class_name GameState;

@export var gameBoard:GameBoard;
@export var hand:Node2D
@export var menu:Node2D

var cardhand;
var account:String="player1";
#Stats.TurretExtension
var unlockedExtensions=[Stats.TurretExtension.DEFAULT];
#Stats.TurretColor
var unlockedColors=[Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedSpecialCards=[Stats.SpecialCards.HEAL];

var phase:Stats.GamePhase=Stats.GamePhase.BUILD;
var bulletManager:BulletManager
var HP=Stats.playerHP;
var maxHP=Stats.playerMaxHP;
var maxCards=5;
var cardRedraws=2;
var totalExp=0;
var levelUp=10;
var started=false;


var wave:int=0;
var stateDictionary={
	"account":"player1",
	"unlockedColors":[Stats.TurretColor.BLUE],
	"unlockedExtensions":[],	
	"unlockedSpecialCards":[Stats.SpecialCards.HEAL],
	"phase":Stats.GamePhase.BOTH,
	"HP":Stats.playerHP,
	"maxHP":Stats.playerMaxHP,
	"handCards":[],
	"wave":0
}
#subject to change
var handCards=[]

signal player_died
signal start_build_phase;
signal start_combat_phase;
signal level_up(item)

@export   var cam:Camera2D;
static var gameState;

func updateDic():
	for k in stateDictionary.keys():
		stateDictionary[k]=get(k)
	pass
func updateValues():
	for k in stateDictionary.keys():
		set(k,stateDictionary[k])
		
	pass;
func upMaxCards():
	maxCards=maxCards+1;
	$CanvasLayer/UI/maxcards.text="MAXCARDS: "+str(maxCards)
	pass;
func upRedraws():
	cardRedraws=cardRedraws+1;
	$CanvasLayer/UI/redraws.text="REDRAWS: "+str(cardRedraws)
	pass;
func changeHealth(amount:int):
	HP=HP+amount
	
	if HP>=maxHP:
		HP=maxHP;
		
	if HP<=0:
		player_died.emit()
	$CanvasLayer/UI/HP.text=str(HP)
	pass;
	
func changeMaxHealth(amount:int):
	maxHP=maxHP+amount
	
	util.p("debug MAXhp: "+str(maxHP))
	pass;


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count()==0:
		queue_free()
	gameState=self;
	
	Engine.max_fps=30;
	#get_tree().create_timer(1).timeout.connect(drawCards.bind(maxCards))
	pass # Replace with function body.
 
func getCamera():

	return cam	
	
	
func drawCards(amount):
	for n in range(amount):
		get_tree().create_timer((n as float)/3).timeout.connect(hand.drawCard)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_start_battle_phase_pressed():
	$Spawner.start(wave)
	wave=wave+1;
	phase=Stats.GamePhase.BATTLE
	$CanvasLayer/UI/PHASE.text="BATTLEPHASE"
	pass # Replace with function body.
func startBuildPhase():
	startCatastrophy()	
	start_build_phase.emit()
	phase=Stats.GamePhase.BUILD
	$CanvasLayer/UI/PHASE.text="BUILDPHASE"
	drawCards(cardRedraws)	
		
	pass;
func startCatastrophy():
	#gameBoard.BULLDOZER_catastrophy(catastrophy_done)
	#gameBoard.call("BULLDOZER_catastrophy").bind(catastrophy_done)
	if wave%1!=0:	return
	gameBoard.extend_field()
	var cat=Stats.getRandomCatastrophy();
	util.p(cat+"_catastrophy called")
	if not gameBoard.has_method(cat+"_catastrophy"): return
	gameBoard.call(cat+"_catastrophy",catastrophy_done)
	
	pass;
func catastrophy_done(finished):
	print(finished)
	pass;
func _on_spawner_wave_done():
	startBuildPhase()
	
	pass # Replace with function body.


func _on_button_pressed():
	gameBoard.draw_field()
	if not started:
		drawCards(maxCards)
		started=true;
	pass # Replace with function body.
func addExp(monster:Monster):
	totalExp=totalExp+monster.getExp()
	$CanvasLayer/UI/EXP.text=str(totalExp)
	checkLevelUp()
	
	pass;
func checkLevelUp():
	if totalExp<levelUp: return
	levelUp=levelUp*2;
	
	var rand=Stats.rng.randi_range(0,100);
	if rand>50:
		level_up.emit(Stats.TurretExtension.keys()[unlockRandom(Stats.TurretExtension.values(),unlockedExtensions)-1])
	else:
		level_up.emit(Stats.SpecialCards.keys()[unlockRandom(Stats.SpecialCards.values(),unlockedSpecialCards)-1])
	
	pass;
func unlockRandom(base,pool):
	var tounlock=[]
	for a in base:
		if not pool.has(a):
			tounlock.append(a)
	var unlocked=tounlock[Stats.rng.randi_range(0,tounlock.size()-1)]
	pool.append(unlocked)
	return unlocked;
	

func _on_area_2d_area_entered(area):
	var m=area.get_parent()
	if m is Monster:
		changeHealth(-m.damage)
		m.monster_died.emit(m)
		m.queue_free()
		
	pass # Replace with function body.
