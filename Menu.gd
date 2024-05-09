extends Node2D
class_name Menu
@export var gamestate:GameState
signal statePropagation(gamestate:GameState)
@export var description:Label
# Called when the node enters the scene tree for the first time.
func _ready():
	statePropagation.emit(gamestate)
	gamestate.start_combat_phase.connect(func():
		$CanvasLayer/UI/Battlephase/AnimatedSprite2D.play("default")
		var tween=create_tween()
		tween.tween_property($CanvasLayer/UI/Battlephase,"position",Vector2(1047.788,42.478),1);
		tween.tween_property($CanvasLayer/UI/Battlephase,"position",Vector2(1041.531,-42),1).set_delay(2.5);
		)
	gamestate.start_build_phase.connect(func():
		var tween=create_tween()
		tween.tween_property($CanvasLayer/UI/BuildPhase,"position",Vector2(1047.788,42.478),1);
		tween.tween_property($CanvasLayer/UI/BuildPhase,"position",Vector2(1041.531,-42),1).set_delay(2.5);
		)	
	pass # Replace with function body.
func updateUI():
	$CanvasLayer/UI/Killcount.text=gamestate.count;
	$CanvasLayer/PlayerName.text=gamestate.account
	$CanvasLayer/UI/Hpbar.max_value=gamestate.maxHP
	$CanvasLayer/UI/Hpbar.value=gamestate.HP
	$CanvasLayer/UI/Wave.text=str(gamestate.wave)
	$CanvasLayer/UI/maxcards.text=str(gamestate.maxCards)
	$CanvasLayer/UI/redraws.text=str(gamestate.cardRedraws)
	$CanvasLayer/UI/EXPbar.max_value=gamestate.levelUp;
	$CanvasLayer/UI/EXPbar.value=gamestate.totalExp
	$CanvasLayer/UI/EXPbar.min_value=gamestate.levelUp/2
	$CanvasLayer/UI/CatBar.value=gamestate.wave%5
	$CanvasLayer/UI/StartBattlePhase.disabled=gamestate.phase==Stats.GamePhase.BATTLE
	
	$CanvasLayer/UI/Hpbar/maxhp.text=str(int(gamestate.maxHP))
	#var hpscale=remap(gamestate.maxHP,200,1000,1,20)
	#$CanvasLayer/UI/Hpbar.scale.y=hpscale
	
	
	pass;

func showDescription(s):
	description.text=s
	sd=true;
	pass;
	
func hideDescription():
	sd=false;
	pass;
func show_tutorial(tut:Tutorial):
	$CanvasLayer/UI/TutorialSpot.add_child(tut)
	tut.modulate=Color(0,0,0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(tut,"modulate",Color(1,1,1,1),1)
	pass;
func showDeathScreen():
	
	$CanvasLayer/AnimationPlayer.play("DeathScreen")
	pass;
func createNewGame():
	gamestate.initNewBoard()
	pass;
var m:float=0	
var s:float=0
var saving=false;
var sd=false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkDescription(delta)
	checkSaving(delta)
	pass
	
func checkSaving(delta):
	
	if saving:
		s=s+2*delta;
	else:
		s=s-2*delta	
	s=clamp(s,0,1)		
	$CanvasLayer/UI/saving.modulate=Color(s,s,s,s)
	pass;
func checkDescription(delta):
	
	if (sd and m >=1) or (not sd and m<=0):
		return
	
	if sd:
		m=m+2*delta;
	else:
		m=m-2*delta	
	m=clamp(m,0,1)	
	description.modulate=Color(m,m,m,m)	
	
	pass;
func showSaving():
	saving=true;
	get_tree().create_timer(1.5).timeout.connect(hideSaving)
	pass;
func hideSaving():
	saving=false;
	pass;
func _on_start_battle_phase_pressed():
	gamestate.startBattlePhase()
	pass # Replace with function body.


func _on_start_button_pressed():
	$CanvasLayer/UI/Hand.visible=true
	pass # Replace with function body.


func _on_button_pressed():
	gamestate.gameBoard._spawn_all_turrets()
	pass # Replace with function body.
