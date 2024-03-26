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

var phase:Stats.GamePhase=Stats.GamePhase.BUILD;

var HP=Stats.playerHP;

#subject to change
var handCards=[]






# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
