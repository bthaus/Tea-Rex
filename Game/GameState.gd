extends Node2D
class_name GameState;

@export var gameBoard:Node2D;

var account:String="player1";
#Stats.TurretExtension
var unlockedExtensions=[];
#Stats.TurretColor
var unlockedColors=[Stats.TurretColor.BLUE];
#Stats.SpecialCards
var unlockedSpecialCards=[Stats.SpecialCards.HEAL];

var phase:Stats.GamePhase=Stats.GamePhase.BOTH;

var HP=Stats.playerHP;
var maxHP=Stats.playerMaxHP;

var wave:int=0;

#subject to change
var handCards=[]

signal player_died



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
	
	changeHealth(-50);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
