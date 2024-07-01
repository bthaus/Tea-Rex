extends Node2D
class_name Menu
@export var gamestate:GameState
signal statePropagation(gamestate:GameState)

var music;
# Called when the node enters the scene tree for the first time.
func _ready():
	
	music=Sounds.playFromCamera(gamestate,Sounds.music[3],false,func():
		music.stream=Sounds.loop
		music.play()
		print("loop"))
	
	statePropagation.emit(gamestate)
	 
			
	pass # Replace with function body.
func stopMusic():
	if music!=null and music.playing:music.stop()
	pass;	
func updateUI():
	$CanvasLayer/PlayerName.text=gamestate.account
	$CanvasLayer/UI/Hpbar.max_value=gamestate.maxHP
	$CanvasLayer/UI/Hpbar.value=gamestate.HP
	$CanvasLayer/UI/Wave.text=str("    ", gamestate.wave)
	$CanvasLayer/UI/maxcards.text=str("    ", gamestate.maxCards)
	$CanvasLayer/UI/redraws.text=str("    ", gamestate.cardRedraws)
	$CanvasLayer/UI/CatBar.value=gamestate.wave%5
	$CanvasLayer/UI/StartBattlePhase.disabled=gamestate.phase==Stats.GamePhase.BATTLE
	$CanvasLayer/UI/Hpbar/maxhp.text=str(int(gamestate.HP))
	
	pass;
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


func _on_menu_button_pressed():
	if not Card.isCardSelected:
		visible=true
		$CanvasLayer.menu.visible=true
		$CanvasLayer/UI.visible=false
	pass # Replace with function body.


func _on_sound_button_pressed():
	Sounds.sound=!Sounds.sound;
	if Sounds.sound:
		$CanvasLayer/MainMenu/SoundButton/Sprite2D.texture=load("res://Assets/UI/unmuted.png")
	else:$CanvasLayer/MainMenu/SoundButton/Sprite2D.texture=load("res://Assets/UI/muted.png")	
	#gamestate.setSound(Sounds.sound)
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, !Sounds.sound) # or false	
	
	pass # Replace with function body.


func _on_account_input_focus_exited():
	pass # Replace with function body.


func _on_speed_button_pressed(val):
	gamestate.toggleSpeed(val)
	pass # Replace with function body.
