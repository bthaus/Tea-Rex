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
var toUnlock=[]
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
var showTutorials=true;

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


var unlock=[]

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
var deathscalling=false;
func changeHealth(amount:int):
	HP=HP+amount
	
	if HP>=maxHP:
		HP=maxHP;
		
	if HP<=0 and !deathscalling:
		deathscalling=true;
		gameBoard.reset()
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

	toUnlock.append_array(Stats.TurretExtension.keys())
	toUnlock.append_array(Stats.SpecialCards.keys())
	toUnlock.erase("DEFAULT")
	toUnlock.erase("HEAL")
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
	if Input.is_action_just_pressed("save"):
		for k in TutorialHolder.tutNames.keys():
			GameSaver.save("0",k,"tutorials")
			print("restored: "+k)	
		GameState.gameState.showTutorials=true	
	
	pass

func initNewBoard():
	
	gameBoard.free()
	board_height=16;
	var newBoard=load("res://GameBoard/game_board.tscn").instantiate()
	gameBoard=newBoard;
	gameBoard.gameState=self
	for s in spawners:
		s.free()
	spawners.clear()
	gameBoard.init_field()
	add_child(gameBoard)
	HP=Stats.playerMaxHP
	maxHP=Stats.playerMaxHP
	for c in hand.get_children():
		c.free()
	drawCards(5)
	maxCards=5;
	cardRedraws=2;
	phase=Stats.GamePhase.BUILD;

	wave=0;
	Spawner.numMonstersActive=0;
	GameSaver.saveGame(self)
	deathscalling=false;
	updateUI()
	pass;
func startBattlePhase():
	
	start_combat_phase.emit()
	menu.get_node("CanvasLayer/UI/StartBattlePhase").disabled=true;
	averageColorChances()
	gameBoard._set_navigation_region()
	get_tree().create_timer(0.5).timeout.connect(func():GameSaver.saveGame(gameState))
	$Camera2D/SoundPlayer.stream=Sounds.StartBattlePhase
	$Camera2D/SoundPlayer.play(0.2)
	for s in spawners:
		s.start(wave)
	
	phase=Stats.GamePhase.BATTLE
	updateUI()
	pass # Replace with function body.
func startBuildPhase():
	
	Sounds.start(Sounds.startBuildPhase)
	GameSaver.saveGame(gameState)
	wave=wave+1;
	menu.get_node("CanvasLayer/UI/StartBattlePhase").disabled=false;
	if not startCatastrophy():
		for u in unlock:
			$Menu/CanvasLayer/UI/UnlockSpot.add_child(u)	
		unlock.clear()		
	start_build_phase.emit()
	phase=Stats.GamePhase.BUILD
	averageColorChances()
	drawCards(cardRedraws)	
	updateUI()	
	#if unlock.size()>0:
		#$Camera2D/UnlockSpot.add_child(unlock[0])
		#for u in range(unlock.size()):
		#	if unlock.size()>=u+1:
		#		unlock[u].done=func():$Camera2D/UnlockSpot.add_child(unlock[u+1])
	
		
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
	if wave%5!=0:	return false
	if wave%10==0: hand.drawCard(Card.create(self,SpecialCard.create(self,Stats.SpecialCards.UPDRAW)))
	if wave%7==0: hand.drawCard(Card.create(self,SpecialCard.create(self,Stats.SpecialCards.UPMAXCARDS)))

	
	var cat=Stats.getRandomCatastrophy();
	
	
	while true:
		cat=Stats.getRandomCatastrophy();
		if gameBoard.has_method(cat+"_catastrophy"):
			break;
	util.p(cat+"_catastrophy called")	
	gameBoard.call(cat+"_catastrophy",catastrophy_done)
	
	return true;
	pass;
func catastrophy_done(finished):
	gameBoard.start_extension(func():get_tree().create_timer(3).timeout.connect(func():
		for u in unlock:
			$Menu/CanvasLayer/UI/UnlockSpot.add_child(u)	
		unlock.clear()	
		
		))
	
	
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
	
	
	var unlocked=unlockRandom()
	var color;
	if unlocked.contains("BLUE"):color=Stats.TurretColor.BLUE
	if unlocked.contains("GREEN"):color=Stats.TurretColor.GREEN
	if unlocked.contains("RED"):color=Stats.TurretColor.RED
	if unlocked.contains("YELLOW"):color=Stats.TurretColor.YELLOW
	var dic=Stats.TurretExtension
	var c;
	if color==null:
		var j=Stats.SpecialCards.get(unlocked)
		unlockedSpecialCards.append(j)
		c=SpecialCard.create(self,j)
		level_up.emit(unlocked)
	else:
		var i=Stats.TurretExtension.get(unlocked)
		unlockedExtensions.append(i)
		var block=Stats.getBlockFromShape(Stats.BlockShape.O,color,1,i);
		c=BlockCard.create(gameState,block)	
		level_up.emit(unlocked)
	
	var card=Card.create(gameState,c);
	var u=Unlockable.create(card)
	unlock.append(u)
	pass;
	
func unlockRandom():
	var unlocked=toUnlock.pick_random()
	toUnlock.erase(unlocked)
	return unlocked;
	
func getColorChances():

	return colorChances
func _on_area_2d_area_entered(area):
	if HP<0: return
	if area == null: return
	var m=area.get_parent()
	if m is Monster:
		
		changeHealth(-m.damage)
		if m == null or not is_instance_valid(m) : return
		#m.monster_died.emit(m)
		m.reached_spawn.emit(m)
		m.queue_free()
		
	pass # Replace with function body.


