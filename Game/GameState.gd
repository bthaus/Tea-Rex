extends Node2D
class_name GameState;

@export var gameBoard: GameBoard;
@export var hand: Node2D
@onready var ui:UI=$CanvasLayer/UI
@export var cam: Camera2D;
@export var lightThresholds: LightThresholds;
static var gameState;



var account: String = "dede";

var unlockedExtensions = [Stats.TurretExtension.BLUELASER];

var unlockedColors = [Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedSpecialCards = [Stats.SpecialCards.HEAL];
var toUnlock = []
var phase: Stats.GamePhase = Stats.GamePhase.BUILD;
var HP = Stats.playerHP;
var maxHP = Stats.playerMaxHP;
var maxCards = 5;
var cardRedraws = 2;

var started = false;
var wave: int = 0;
var board_width = 11;
var board_height = 16;
var background_width = 80
var background_height = 40
var y = 0
var spawners = []
var target;
var showTutorials = false;
var level = 0;
static var game_speed=1;
static var board;

#subject to change
static var bulletHolder;
signal player_died
signal start_build_phase;
signal start_combat_phase;
signal level_up(item)

static var collisionReference=CollisionReference.new()

var unlock = []

func upMaxCards():
	maxCards = maxCards + 1;
	updateUI()
	pass ;
func upRedraws():
	cardRedraws = cardRedraws + 1;
	updateUI()
	pass ;
func updateUI():
	ui.updateUI();
	pass ;
func registerSpawner(spawner: Spawner):
	spawners.append(spawner)
	pass ;
var deathscalling = false;
func changeHealth(amount: int):
	HP = HP + amount
	
	if HP >= maxHP:
		HP = maxHP;
		
	if HP <= 0 and !deathscalling:
		deathscalling = true;
		gameBoard.reset()
		player_died.emit()
	updateUI()
	pass ;
	
func changeMaxHealth(amount: int):
	maxHP = maxHP + amount
	
	updateUI()
	pass ;
var count = " ";
func showCount(killcount, damage):
	count = str(str(killcount) + "kills and " + str(damage) + "damage dealt")
	updateUI()
	pass ;
func hideCount():
	count = " "
	updateUI()
	pass ;
# Called when the node enters the scene tree for the first time.
var mapdrawnOnce = false;
func toggleSpeed(val):
	if GameState.game_speed+val>5: return
	if GameState.game_speed+val<1:return;
	GameState.game_speed=GameState.game_speed+val;
	Engine.time_scale=GameState.game_speed
	
	pass;
func _ready():
	if get_child_count() == 0:
		queue_free()
		return
	gameState = self;
	ui=$CanvasLayer/UI
	hand=ui.hand
	ui.initialise()
	game_speed=1;
	toggleSpeed(0)
	#collisionReference.initialise(self)
	bulletHolder = $BulletHolder
	toUnlock.append_array(Stats.TurretExtension.keys())
	toUnlock.append_array(Stats.SpecialCards.keys())
	toUnlock.erase("DEFAULT")
	toUnlock.erase("HEAL")
	toUnlock.erase("UPDRAW")
	Engine.max_fps=60
	
	
	GameSaver.createBaseGame(self)
	target = $Base
	startGame()
	pass # Replace with function body.
 
func getCamera():
	return cam
	
func drawCards(amount):
	for n in range(amount):
		get_tree().create_timer((n as float) / 3).timeout.connect(hand.drawCard)
	pass ;
# Called every frame. 'delta' is the elapsed time since the previous frame.


		
func _process(delta):

	for i in range(game_speed):
		for turret in Turret.turrets:
			if is_instance_valid(turret): turret.do(delta/game_speed);
			else: Turret.turrets.erase(turret)
		for turret in Turret.inhandTurrets:
			if is_instance_valid(turret): turret.do(delta/game_speed);
			else: Turret.turrets.erase(turret)
		$MinionHolder.do(delta/game_speed)
		$BulletHolder.do(delta/game_speed)		
	y = cam.position.y
	
	if Input.is_action_just_pressed("save"):
		#gameBoard.queue_free()
		#menu.queue_free()
		var delay=0;
		#maxCards=100
		print("drawing")
		maxCards=100
		hand.drawCard(Card.create(self,SpecialCard.create(self,Stats.SpecialCards.POISON)))
		#changeHealth(-5000)
		#gameBoard.DRILL_catastrophy(func():)
		#for c in hand.get_children():
		#	c.queue_free()
		#hand.drawCard(Card.create(self,BlockCard.create(self,Stats.getBlockFromShape(Stats.BlockShape.TINY,Stats.TurretColor.BLUE,1,Stats.TurretExtension.DEFAULT))))	
		
		#spawners[0].spawnEnemy(Monster.create(Stats.TurretColor.BLUE,target))
		#unlock.append(Unlockable.create(Card.create(self,BlockCard.create(self,Stats.getBlockFromShape(Stats.BlockShape.O,Stats.TurretColor.BLUE,1,Stats.TurretExtension.BLUEFREEZER)))))
		#checkUnlock()
		#GameState.gameState.showTutorials=true	
		#totalExp=50000000;
	#	checkLevelUp()
		#checkUnlock()
		
		
	pass

func initNewBoard():
	gameBoard.free()
	board_height = 16;
	var newBoard = load("res://GameBoard/game_board.tscn").instantiate()
	gameBoard = newBoard;
	gameBoard.gameState = self
	for s in spawners:
		s.free()
	spawners.clear()
	gameBoard.init_field()
	add_child(gameBoard)
	board=gameBoard.get_node("Board")
	collisionReference.queue_free()
	collisionReference=CollisionReference.new()
	collisionReference.initialise(self)
	$MinionHolder.board=board
	$BulletHolder.board=board;
	cleanUpAllFreedNodes()
	HP = Stats.playerMaxHP
	maxHP = Stats.playerMaxHP
	for c in hand.get_children():
		c.free()
	drawCards(5)
	maxCards = 5;
	cardRedraws = 2;
	phase = Stats.GamePhase.BUILD;

	wave = 0;
	Spawner.numMonstersActive = 0;
	GameSaver.saveGame(self)
	deathscalling = false;
	updateUI()
	cam.move_to(Vector2(500, 500), func(): print("done"))
	pass ;
func startBattlePhase():
	var mo=Monster.create(Stats.getRandomColor(self),target,1)
	mo.global_position=Vector2(500,500)
	mo.monster_died.connect(startBuildPhase)
	$MinionHolder.add_child(mo)
	return
	
	GameState.game_speed=GameState.restore_speed
	toggleSpeed(0)
	Spawner.numMonstersActive = 0;
	start_combat_phase.emit()
	ui.get_node("StartBattlePhase").disabled = true;
	gameBoard._set_navigation_region()
	get_tree().create_timer(0.5).timeout.connect(func(): GameSaver.saveGame(gameState))
	$Camera2D/SoundPlayer.stream = Sounds.StartBattlePhase
	$Camera2D/SoundPlayer.play(0.2)
	for s in spawners:
		s.start(wave)
	phase = Stats.GamePhase.BATTLE
	updateUI()
	pass # Replace with function body.
func cleanUpAllFreedNodes():
	for m in $MinionHolder.get_children():
		if is_instance_valid(m):m.queue_free()
	collisionReference.clearUp()	
	pass;	
static var restore_speed=1;	
func startBuildPhase():
	if GameState.game_speed!=null:
		GameState.restore_speed=GameState.game_speed
		GameState.game_speed=1
	else:
		GameState.restore_speed=1;
		GameState.game_speed=1;	
	toggleSpeed(0)
	cleanUpAllFreedNodes()
	Sounds.start(Sounds.startBuildPhase)
	GameSaver.saveGame(gameState)
	wave = wave + 1;
	var delayUnlock = false;
	if wave == 1:
		delayUnlock = TutorialHolder.showTutorial(TutorialHolder.tutNames.EXP, self, checkUnlock)
	if wave == 2:
		delayUnlock = TutorialHolder.showTutorial(TutorialHolder.tutNames.Pathfinding, self, checkUnlock)
	if wave == 3:
		delayUnlock = TutorialHolder.showTutorial(TutorialHolder.tutNames.Information, self, checkUnlock)
	if wave == 4:
		delayUnlock = TutorialHolder.showTutorial(TutorialHolder.tutNames.UpgradeBlocks, self, checkUnlock)
	if wave == 5:
		delayUnlock = false;
	if wave == 6:
		delayUnlock = TutorialHolder.showTutorial(TutorialHolder.tutNames.UpgradeBlocks2, self, checkUnlock)
	if wave > 6:
		delayUnlock = false;
	ui.get_node("StartBattlePhase").disabled = false;
	
	if !delayUnlock:
		checkUnlock()
	start_build_phase.emit()
	phase = Stats.GamePhase.BUILD
	drawCards(cardRedraws)
	updateUI()
	
	pass ;
var index: int = 0;

func checkUnlock():
	for u in unlock:
		ui.get_node("UnlockSpot").add_child(u)
	unlock.clear()
	GameSaver.saveGame(self)
	pass ;
func _on_spawner_wave_done():
	startBuildPhase()
	pass # Replace with function body.

func startGame():
	GameState.restore_speed=1;
	GameState.game_speed=1;	
	collisionReference.initialise(self)
	collisionReference.addRows()
	board=gameBoard.get_node("Board")
	collisionReference.registerBase(target)
	$MinionHolder.board=board
	$BulletHolder.board=board;
	for m in $MinionHolder.get_children():
		m.queue_free()
		
	#menu.stopMusic()
	cam.move_to(Vector2(500, 500), func(): print("done"))
	TutorialHolder.showTutorial(TutorialHolder.tutNames.Starting, self, func():
		TutorialHolder.showTutorial(TutorialHolder.tutNames.RotateBlock, self, func():
			TutorialHolder.showTutorial(TutorialHolder.tutNames.Controls, self)
			)
		)
		
	hand.visible = true;
	if not started:
		target = $Base
		drawCards(maxCards)
		gameBoard.init_field()
		started = true;
	updateUI()
	pass # Replace with function body.


	


func hit_base(m):
	if HP < 0: return
	
	if m is Monster:
		
		changeHealth( - m.damage)
		if m == null or not is_instance_valid(m): return
		m.reached_spawn.emit(m)
		m.queue_free()
		
	pass # Replace with function body.

func mortarWorkaround(damage, pos, associate):
	var sprite = Sprite2D.new();
	sprite.texture = load("res://Assets/UI/Target_Cross.png")
	get_parent().add_child(sprite)
	sprite.global_position = pos;
	
	get_tree().create_timer(1).timeout.connect(func():
		
		Explosion.create(Stats.TurretColor.YELLOW, damage, pos, associate, 0.5)
		sprite.queue_free()
	)
	
	pass ;

	
func GetAllTreeNodes( node = get_tree().root,  listOfAllNodesInTree = []):
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree
		
