extends GameObject2D
class_name GameState;

@export var gameBoard: GameBoard;
@export var hand: Node2D
@onready var ui:UI=$CanvasLayer/UI
@export var cam: Camera2D;

enum GamePhase {BATTLE=1,BUILD=2,BOTH=3};
var current_expected_damage=0:
	set(value):
		current_expected_damage=value
		updateUI()
static var gameState:GameState
	#get:
		#if gameState==null:
			#gameState=load("res://Game/main_scene.tscn").instantiate()
			#MainMenu.instance.add_child(gameState)
		#return gameState	
var account: String = "dede";

#Todo: remove and replace with battle_slot_logic
var unlockedExtensions = [Turret.Extension.DEFAULT];
var unlockedColors =[Turret.Hue.MAGENTA] #[Turret.Hue.GREEN,Turret.Hue.BLUE,Turret.Hue.RED,Turret.Hue.YELLOW];

var selected_battle_slots

var toUnlock = []
var phase: GameState.GamePhase = GameState.GamePhase.BUILD;
var HP = GameplayConstants.playerHP;
var maxHP = GameplayConstants.playerMaxHP;
var maxCards = 5;
var cardRedraws = 2;


var wave: int = 0;
var board_width = 11;
var board_height = 16;
var background_width = 80
var background_height = 40

static var portals:Array[Portal]=[]
static var spawners:Array[Spawner] = []
var target;
var targets=[]
var showTutorials = false;
var minions
static var game_speed=1;
static var board;

#subject to change
static var bulletHolder;

signal player_died
signal start_build_phase;
signal start_combat_phase;

static var collisionReference:CollisionReference=CollisionReference.new()
var map_dto;

static var monsters
var containers=[]
func register_battle_slot_containers(containers:Array[TurretModContainerDTO]):
	self.containers=containers
	unlockedColors.clear()
	for container in containers:
		unlockedColors.push_back(container.color)
	if unlockedColors.is_empty():
		unlockedColors.push_back(Turret.Hue.MAGENTA)	
	TurretCoreFactory.register_mod_containers(containers)	
	
	pass;

func apply_mods_before_start():
	for c:TurretModContainerDTO in containers:
		for item:ItemBlockDTO in c.turret_mods:
			item.turret_mod.before_game_start(c.color)
	pass;

func _ready():
	monsters=$MinionHolder
	gameState = self;
	ui=$CanvasLayer/UI
	hand=ui.hand
	ui.initialise()
	game_speed=1;
	toggleSpeed(0)
	bulletHolder = $BulletHolder
	Engine.max_fps=60
	target = $Base
	startGame()
	pass # Replace with function body.
 
func _draw():
	for portal in GameState.gameState.portals:
		var pp=GameState.board.map_to_local(portal.map_position)
		for to_connect in GameState.gameState.portals:
			if portal==to_connect:continue
			var tp=GameState.board.map_to_local(to_connect.map_position)
			if portal.group_id==to_connect.group_id:
				draw_line(pp-global_position,tp-global_position,Color.ALICE_BLUE,4)
	pass;
		
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
	
	pass

func add_target(t):
	target=t
	targets.append(t)
	pass;

func startBattlePhase():
	for turret in Turret.turrets:
		turret.clear_path()
	for s in spawners:
		for path in s.paths:
			for cell in path.path:
				collisionReference.register_path_cell_in_turrets(cell)
	for turret in Turret.turrets:
		print(turret.base.path_cells.size())			
	GameState.game_speed=GameState.restore_speed
	toggleSpeed(0)
	Spawner.numMonstersActive = 0;
	start_combat_phase.emit()
	ui.get_node("StartBattlePhase").disabled = true;
	
	
	$Camera2D/SoundPlayer.stream = Sounds.StartBattlePhase
	$Camera2D/SoundPlayer.play(0.2)
	
	start_wave(wave)
	phase = GameState.GamePhase.BATTLE
	updateUI()
	
	pass # Replace with function body.
func start_wave(wave):
	for s in spawners:
		s.start(wave)
	pass;


func startBuildPhase():
	
	if GameState.game_speed!=null:
		GameState.restore_speed=GameState.game_speed
		GameState.game_speed=1
	else:
		GameState.restore_speed=1;
		GameState.game_speed=1;	
	toggleSpeed(0)
	wave = wave + 1;
	start_build_phase.emit()
	if wave==map_dto.number_of_waves:
		win_game()
	
	cleanUpAllFreedNodes()
	Sounds.start(Sounds.startBuildPhase)
	

	if wave == 1:
		TutorialHolder.showTutorial(TutorialHolder.tutNames.EXP, self)
	if wave == 2:
		TutorialHolder.showTutorial(TutorialHolder.tutNames.Pathfinding, self)
	if wave == 3:
		TutorialHolder.showTutorial(TutorialHolder.tutNames.Information, self)
	if wave == 4:
		TutorialHolder.showTutorial(TutorialHolder.tutNames.UpgradeBlocks, self)
	if wave == 6:
		TutorialHolder.showTutorial(TutorialHolder.tutNames.UpgradeBlocks2, self)

	ui.get_node("StartBattlePhase").disabled = false;

	
	phase = GameState.GamePhase.BUILD
	drawCards(cardRedraws)
	updateUI()
	
	pass ;


func startGame():
	portals.clear()
	spawners.clear()
	collisionReference.initialise(self,map_dto)
	gameBoard=load("res://GameBoard/game_board.tscn").instantiate()
	add_child(gameBoard)
	board=gameBoard.get_node("Board")
	gameBoard.init_field(map_dto)
	apply_mods_before_start()
	
	
	GameState.restore_speed=1;
	GameState.game_speed=1;	
	
	minions=$MinionHolder
	$MinionHolder.board=board
	$BulletHolder.board=board;
	
	for target in targets:
		collisionReference.registerBase(target)
	
		
	cam.move_to(Vector2(500, 500), func(): print("done"))
	TutorialHolder.showTutorial(TutorialHolder.tutNames.Starting, self, func():
		TutorialHolder.showTutorial(TutorialHolder.tutNames.RotateBlock, self, func():
			TutorialHolder.showTutorial(TutorialHolder.tutNames.Controls, self)
			)
		)
		
	hand.visible = true;
	target = $Base
	drawCards(maxCards)
	updateUI()
	for s in spawners:
		s.refresh_path()
	queue_redraw()	
	#board.global_rotation_degrees=45
	pass # Replace with function body.


	
func win_game():
	var win=load("res://menu_scenes/win_screen_scenes/win_scene.tscn").instantiate()
	win.set_up(self)
	$CanvasLayer/UI.add_child(win)
	
	pass;

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
		
		Explosion.create(Turret.Hue.GREEN, damage, pos, associate, 0.5)
		sprite.queue_free()
	)
	
	pass ;


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

func toggleSpeed(val):
	if GameState.game_speed+val>5: return
	if GameState.game_speed+val<1:return;
	GameState.game_speed=GameState.game_speed+val;
	Engine.time_scale=GameState.game_speed
	
	pass;
	
func GetAllTreeNodes( node = get_tree().root,  listOfAllNodesInTree = []):
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree
		
func getCamera():
	return cam
	
func drawCards(amount):
	for n in range(amount):
		get_tree().create_timer((n as float) / 3).timeout.connect(hand.drawCard)
	pass ;
	
	
func cleanUpAllFreedNodes():
	for m in $MinionHolder.get_children():
		if is_instance_valid(m):m.queue_free()
	collisionReference.clearUp()	
	pass;	
static var restore_speed=1;	

func _on_spawner_wave_done():
	startBuildPhase()
	pass # Replace with function body.
	


func _on_tree_exited():
	queue_free()
	pass # Replace with function body.
