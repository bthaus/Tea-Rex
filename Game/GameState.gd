extends Node2D
class_name GameState;

@export var gameBoard:GameBoard;
@export var hand:Node2D
@export var menu:Menu
@export var cam:Camera2D;
@export var lightThresholds:LightThresholds;
static var gameState;


var account:String="";
#Stats.TurretExtension
var unlockedExtensions=[Stats.TurretExtension.DEFAULT];
#Stats.TurretColor
var unlockedColors=[Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedSpecialCards=[Stats.SpecialCards.HEAL];

var phase:Stats.GamePhase=Stats.GamePhase.BUILD;
var HP=Stats.playerHP;
var maxHP=Stats.playerMaxHP;
var maxCards=5;
var cardRedraws=2;
var totalExp=0;
var levelUp=250;
var started=false;
var wave:int=0;
var board_width=11;
var board_height=16;
var y=0
var spawners=[]
var target;

static var blueChance=100;
static var redChance=0;
static var greenChance=0;
static var yellowChance=0;
static var greyChance=0;
var colorChances = [greyChance, greenChance, redChance, yellowChance, blueChance]
#subject to change


signal player_died
signal start_build_phase;
signal start_combat_phase;
signal level_up(item)




func upMaxCards():
	maxCards=maxCards+1;
	updateUI()
	pass;
func upRedraws():
	cardRedraws=cardRedraws+1;
	updateUI()
	pass;
func updateUI():
	menu.updateUI();
	pass;
func registerSpawner(spawner:Spawner):
	spawners.append(spawner)
	pass;
func changeHealth(amount:int):
	HP=HP+amount
	
	if HP>=maxHP:
		HP=maxHP;
		
	if HP<=0:
		player_died.emit()
	updateUI()
	pass;
	
func changeMaxHealth(amount:int):
	maxHP=maxHP+amount
	
	updateUI()
	pass;
var count=" ";
func showCount(killcount,damage):
	count=str(str(killcount)+"kills and "+str(damage)+"damage dealt")
	updateUI()
	pass;
func hideCount():
	count=" "
	updateUI()
	pass;
# Called when the node enters the scene tree for the first time.
var mapdrawnOnce=false;
func _ready():

	if get_child_count()==0:
		queue_free()
	
	gameState=self;
	Engine.max_fps=30;
	GameSaver.createBaseGame(self)
	target=$Base
	
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
	y=cam.position.y
		
	pass


func startBattlePhase():
	menu.get_node("CanvasLayer/UI/StartBattlePhase").disabled=true;
	averageColorChances()
	gameBoard._set_navigation_region()
	get_tree().create_timer(0.5).timeout.connect(func():GameSaver.saveGame(gameState))
	
	for s in spawners:
		s.start(wave)
	
	phase=Stats.GamePhase.BATTLE
	updateUI()
	pass # Replace with function body.
func startBuildPhase():
	GameSaver.saveGame(gameState)
	wave=wave+1;
	menu.get_node("CanvasLayer/UI/StartBattlePhase").disabled=false;
	startCatastrophy()	
	start_build_phase.emit()
	phase=Stats.GamePhase.BUILD
	averageColorChances()
	drawCards(cardRedraws)	
	updateUI()	
	pass;
var index:int=0;	
func averageColorChances():
	if colorChances[Stats.TurretColor.BLUE-1]>20:
		index=(index+1)%4
		colorChances[Stats.TurretColor.BLUE-1]=colorChances[Stats.TurretColor.BLUE-1]-10
		colorChances[index]=colorChances[index]+10
	pass;
func startCatastrophy():
	
	#gameBoard.BULLDOZER_catastrophy(catastrophy_done)
	#gameBoard.call("BULLDOZER_catastrophy").bind(catastrophy_done)
	if wave%5!=0:	return
	if wave%10==0: hand.drawCard(Card.create(self,SpecialCard.create(self,Stats.SpecialCards.UPDRAW)))
	if wave%7==0: hand.drawCard(Card.create(self,SpecialCard.create(self,Stats.SpecialCards.UPMAXCARDS)))

	
	var cat=Stats.getRandomCatastrophy();
	
	
	while true:
		cat=Stats.getRandomCatastrophy();
		if gameBoard.has_method(cat+"_catastrophy"):
			break;
	util.p(cat+"_catastrophy called")	
	gameBoard.call(cat+"_catastrophy",catastrophy_done)
	gameBoard.extend_field()
	pass;
func catastrophy_done(finished):
	
	pass;
func _on_spawner_wave_done():
	startBuildPhase()
	
	pass # Replace with function body.


func startGame():
	
	if not started:
		target=$Base
		drawCards(maxCards)
		gameBoard.init_field()
		started=true;
	updateUI()	
	pass # Replace with function body.
func addExp(monster:Monster):
	totalExp=totalExp+monster.getExp()
	checkLevelUp()
	updateUI()
	
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
			
	if tounlock.size()==0:
		return; #todo: fix null return
	var unlocked=tounlock[Stats.rng.randi_range(0,tounlock.size()-1)]
	pool.append(unlocked)
	return unlocked;
	
func getColorChances():

	return colorChances
func _on_area_2d_area_entered(area):
	var m=area.get_parent()
	if m is Monster:
		changeHealth(-m.damage)
		m.monster_died.emit(m)
		m.queue_free()
		
	pass # Replace with function body.


func _on_music_finished():
	pass # Replace with function body.
