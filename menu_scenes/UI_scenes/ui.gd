extends GameObject2D
class_name UI
var gamestate:GameState
@onready var hand=$Hand

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
func initialise():
	gamestate=GameState.gameState
	hand.state=gamestate
	gamestate.start_combat_phase.connect(func():
		$Battlephase/AnimatedSprite2D.play("default")
		var tween=create_tween()
		tween.tween_property($Battlephase,"position",Vector2(1047.788,42.478),1);
		tween.tween_property($Battlephase,"position",Vector2(1041.531,-42),1).set_delay(2.5);
		)
	gamestate.start_build_phase.connect(func():
		var tween=create_tween()
		tween.tween_property($BuildPhase,"position",Vector2(1047.788,42.478),1);
		tween.tween_property($BuildPhase,"position",Vector2(1041.531,-42),1).set_delay(2.5);
		)
	pass;	
func updateUI():
	$Hpbar.max_value=gamestate.maxHP
	$Hpbar.value=gamestate.HP
	$Wave.text=str("    ", gamestate.wave)
	$maxcards.text=str("    ", gamestate.maxCards)
	$redraws.text=str("    ", gamestate.cardRedraws)
	$CatBar.value=gamestate.wave%5
	$StartBattlePhase.disabled=gamestate.phase==GameState.GamePhase.BATTLE
	$Hpbar/maxhp.text=str(int(gamestate.HP))
	$expected_damage.text=str(int(gamestate.current_expected_damage))+" expected damage"
	
	pass;
func show_tutorial(tut:Tutorial):
	$TutorialSpot.add_child(tut)
	tut.modulate=Color(0,0,0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(tut,"modulate",Color(1,1,1,1),1)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _on_start_battle_phase_pressed():
	gamestate.startBattlePhase()
	pass # Replace with function body.

func _on_speed_button_pressed(val):
	gamestate.toggleSpeed(val)
	pass # Replace with function body.
	
@export var description:Label
func showDescription(s):
	description.text=s
	sd=true;
	pass;
	
func hideDescription():
	sd=false;
	pass;

func showDeathScreen():
	
	$CanvasLayer/AnimationPlayer.play("DeathScreen")
	pass;

var m:float=0	
var s:float=0
var saving=false;
var sd=false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
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
