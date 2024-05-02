extends Node2D
class_name LightThresholds
@export var gameState:GameState

@export var minDarkPosition:Node2D
@export var maxDarkPosition:Node2D
@export var minLightPosition:Node2D
@export var maxLightPosition:Node2D
@export var minGlowPosition:Node2D
@export var maxGlowPosition:Node2D
@export var firstCaveCheck:Node2D
@export var secondCaveCheck:Node2D

@export var spawnerPositions:Array[int]
@export var minDark:float
@export var maxDark:float
@export var minLight:float
@export var maxLight:float
@export var minGlow:float
@export var maxGlow:float
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func getGlow(y):

	var glow=remap(y,minGlowPosition.global_position.y,maxGlowPosition.global_position.y,minGlow,maxGlow)
	glow=clamp(glow,minGlow,maxGlow)
	return glow;
	pass;
func getDark(y):
	var Dark=remap(y,minDarkPosition.global_position.y,maxDarkPosition.global_position.y,minDark,maxDark)
	Dark=clamp(Dark,maxDark,minDark)
	return Dark;
	pass;

func getLight(y):
	var Light=remap(y,minLightPosition.global_position.y,maxLightPosition.global_position.y,minLight,maxLight)
	Light=clamp(Light,minLight,maxLight)
	return Light;
	pass;
func getCaveSpawnerProbability(y):
	
	pass;	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
