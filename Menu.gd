extends Node2D
class_name Menu
@export var gamestate:GameState
signal statePropagation(gamestate:GameState)

# Called when the node enters the scene tree for the first time.
func _ready():
	statePropagation.emit(gamestate)
	pass # Replace with function body.
func updateUI():
	$CanvasLayer/UI/Killcount.text=gamestate.count;
	$CanvasLayer/PlayerName.text=gamestate.account
	$CanvasLayer/UI/Hpbar.max_value=gamestate.maxHP
	$CanvasLayer/UI/Hpbar.value=gamestate.HP
	$CanvasLayer/UI/PHASE.text=Stats.GamePhase.keys()[gamestate.phase-1]
	$CanvasLayer/UI/Wave.text=str(gamestate.wave)
	$CanvasLayer/UI/maxcards.text=str(gamestate.maxCards)
	$CanvasLayer/UI/redraws.text=str(gamestate.cardRedraws)
	$CanvasLayer/UI/EXPbar.max_value=gamestate.levelUp;
	$CanvasLayer/UI/EXPbar.value=gamestate.totalExp
	$CanvasLayer/UI/CatBar.value=gamestate.wave%5
	$CanvasLayer/UI/StartBattlePhase.disabled=gamestate.phase==Stats.GamePhase.BATTLE
	var hpscale=remap(gamestate.maxHP,200,1000,1,20)
	$CanvasLayer/UI/Hpbar.scale.y=hpscale
	
	pass;
func showDeathScreen():
	
	$CanvasLayer/AnimationPlayer.play("DeathScreen")
	pass;
func createNewGame():
	gamestate.initNewBoard()
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_battle_phase_pressed():
	gamestate.startBattlePhase()
	pass # Replace with function body.


func _on_start_button_pressed():
	pass # Replace with function body.


func _on_button_pressed():
	gamestate.gameBoard._spawn_all_turrets()
	pass # Replace with function body.
