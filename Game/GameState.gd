extends Node2D
class_name GameState;

@export var gameBoard:Node2D;
@export var hand:Node2D


var cardhand;
var account:String="player1";
#Stats.TurretExtension
var unlockedExtensions=[];
#Stats.TurretColor
var unlockedColors=[Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedSpecialCards=[Stats.SpecialCards.HEAL];

var phase:Stats.GamePhase=Stats.GamePhase.BOTH;
var bulletManager:BulletManager
var HP=Stats.playerHP;
var maxHP=Stats.playerMaxHP;
var maxCards=5;
var cardRedraws=1;


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
	$CanvasLayer/maxcards.text="MAXCARDS: "+str(maxCards)
	pass;
func upRedraws():
	cardRedraws=cardRedraws+1;
	$CanvasLayer/redraws.text="REDRAWS: "+str(cardRedraws)
	pass;
func changeHealth(amount:int):
	HP=HP+amount
	
	if HP>=maxHP:
		HP=maxHP;
		
	if HP<=0:
		player_died.emit()
	$CanvasLayer/HP.text=str(HP)
	pass;
	
func changeMaxHealth(amount:int):
	maxHP=maxHP+amount
	
	util.p("debug MAXhp: "+str(maxHP))
	pass;


# Called when the node enters the scene tree for the first time.
func _ready():
	
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
	$CanvasLayer/PHASE.text="BATTLEPHASE"
	pass # Replace with function body.
func startBuildPhase():
	startCatastrophy()	
	start_build_phase.emit()
	phase=Stats.GamePhase.BUILD
	$CanvasLayer/PHASE.text="BUILDPHASE"
	drawCards(cardRedraws)	
		
	pass;
func startCatastrophy():
	if wave%5!=0:	return
	
	var cat=Stats.getRandomCatastrophy();
	
	if not gameBoard.has_method(cat+"_catastrophy"): return
	gameBoard.call(cat+"_catastrophy")
	
	pass;
func _on_spawner_wave_done():
	startBuildPhase()
	
	pass # Replace with function body.


func _on_button_pressed():
	gameBoard._draw_walls()
	drawCards(maxCards)
	$CanvasLayer/Button.queue_free()
	pass # Replace with function body.


func _on_area_2d_area_entered(area):
	var m=area.get_parent()
	if m is Monster:
		changeHealth(-m.damage)
	pass # Replace with function body.
