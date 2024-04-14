extends Node2D
class_name GameState;

@export var gameBoard:Node2D;
var cardhand;
var account:String="player1";
#Stats.TurretExtension
var unlockedsExtensions=[];
#Stats.TurretColor
var unlockedsColors=[Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedsSpecialCards=[Stats.SpecialCards.HEAL];

var phase:Stats.GamePhase=Stats.GamePhase.BOTH;
var bulletManager:BulletManager
var HP=Stats.playerHP;
var maxHP=Stats.playerMaxHP;

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
func changeHealth(amount:int):
	HP=HP+amount
	
	if HP>=maxHP:
		HP=maxHP;
		
	if HP<=0:
		player_died.emit()
	util.p("debug hp: "+str(HP))
	pass;
	
func changeMaxHealth(amount:int):
	maxHP=maxHP+amount
	
	util.p("debug MAXhp: "+str(maxHP))
	pass;


# Called when the node enters the scene tree for the first time.
func _ready():
	
	gameState=self;

	Engine.max_fps=30;

	
	pass # Replace with function body.

func getCamera():

	return cam	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_start_battle_phase_pressed():
	$Spawner.start(wave)
	phase=Stats.GamePhase.BATTLE
	$CanvasLayer/PHASE.text="BATTLEPHASE"
	pass # Replace with function body.


func _on_spawner_wave_done():
	phase=Stats.GamePhase.BUILD
	
	$CanvasLayer/PHASE.text="BUILDPHASE"
	pass # Replace with function body.
