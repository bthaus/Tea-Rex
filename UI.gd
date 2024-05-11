extends CanvasLayer
@export var gameState:GameState
@export var main:Node2D
@export var unlockedTab:Node2D
@export var accountsTab:Node2D
@export var menu:Node2D
@export var ui:Node2D
@export var parent:Menu
var tuts;

# Called when the node enters the scene tree for the first time.
func _ready():
	#var map=BitMap.new()
	#map.create_from_image_alpha(load("res://Assets/UI/ShowUnlockedBUtton.png"),0)
	#$MainMenu/Main/UnlockedButton.texture_click_mask=map
	#var map2=BitMap.new()
	#map2.create_from_image_alpha(load("res://Assets/UI/ShowAccountsButton.png"),0)
	#$MainMenu/Main/Accounts
	tuts=$MainMenu/UnlockedTab/TutorialNode
	var offset=0;
	for t in tuts.get_children():
		t.get_node("Button").visible=false;
		t.get_node("CheckButton").visible=false;
		t.translate(Vector2(0,offset))
		t.visible=true;
		offset=offset+800
	tuts.get_children()[tuts.get_child_count()-1].visible=false;
	pass # Replace with function body.
func _input(event):
	
	if event.is_action_pressed("scroll_down")and tuts.global_position.y <550 and unlockedTab.visible:
		tuts.translate(Vector2(0,100))
	if event.is_action_pressed("scroll_up") and tuts.global_position.y>-9000 and unlockedTab.visible:
		tuts.translate(Vector2(0,-100))	
	if event.is_action_pressed("scroll_down")and accoundentries.global_position.y<500 and accountsTab.visible:
		accoundentries.translate(Vector2(0,100))
	if event.is_action_pressed("scroll_up") and accoundentries.global_position.y>-350*accoundentries.get_child_count()+1200 and accountsTab.visible:
		accoundentries.translate(Vector2(0,-100))		
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_menu") and not Card.isCardSelected and gameState.account!="":
		menu.visible=!menu.visible
		$UI.visible=!menu.visible
		
	if Input.is_action_just_pressed("delete"):
		if accountsTab.visible:
			for i in $MainMenu/AccountsTab/AccountList.get_selected_items():
				removeAcc($MainMenu/AccountsTab/AccountList.get_item_text(i))
				$MainMenu/AccountsTab/AccountList.remove_item(i)
				
				
	pass


func _on_start_button_pressed():
	if gameState==null || gameState.account=="":
		showAccounts()
		return
	$MainMenu/Banner.visible=false;
	
	ui.visible=true;
	menu.visible=false;
	$MainMenu/Main/StartButton/Label.text="continue"
	
	#gameState.startGame()
	pass # Replace with function body.


func _on_unlocked_button_pressed():
	main.visible=false;
	unlockedTab.visible=true;
	pass # Replace with function body.
func _on_accounts_pressed():
	main.visible=false;
	showAccounts()
	pass # Replace with function body.

func _on_menu_state_propagation(gamestate):
	
	self.gameState=gamestate
	pass # Replace with function body.

func showAccounts():
	accountsTab.visible=true
	refreshAccountList()
	blinkHint(true)	
	$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.text="Enter your name to start"
	$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.modulate=Color(1,1,1,1)
	pass;

func initAccs():
	var accs=[]
	GameSaver.save(JSON.stringify(accs),"accounts","global")
	pass;

func loadAccs():
	var json=GameSaver.loadfile("accounts","global")
	if json==""||JSON.parse_string(json).size()==0:
		initAccs()
	var acs=JSON.parse_string(json)
	
	return acs
	pass;
func saveAccs(accs):
	var json=JSON.stringify(accs)
	GameSaver.save(json,"accounts","global")
	pass;
	
func selectAcc(name):
	gameState.account=name
	GameSaver.restoreGame(gameState)
	parent.updateUI()
	_on_start_button_pressed()
	gameState.startGame()
	HideAccounts()
	
	pass;	
func saveNewAcc(name):
	var accs=loadAccs()
	gameState.account=name
	if accs!=null and accs.find(name)!=-1:
		$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.text="Name taken!"
		$MainMenu/AccountsTab/Sprite2D2/AccountNameHint.modulate=Color(1,0,0,1)
		return
	accs.append(name);
	saveAccs(accs)
	GameSaver.restoreBaseGame(gameState)
	gameState.startGame()
	_on_start_button_pressed()
	
		
	pass;
func removeAcc(name):
	GameSaver.remove(name)
	var accs=loadAccs()
	accs.erase(name)
	saveAccs(accs)
	
	pass;
	
var accoundentries;	
func refreshAccountList():
	var accs=loadAccs();
	for entry in $MainMenu/AccountsTab/EntryPosition/pos.get_children():
		entry.free()
	AccountEntry.allEntries.clear()
	#$MainMenu/AccountsTab/EntryPosition/pos.global_position=Vector2(-24,-405)
	accoundentries=$MainMenu/AccountsTab/EntryPosition/pos
	var offset=0
	for a in accs:
		var entry=AccountEntry.create(a)
		$MainMenu/AccountsTab/EntryPosition/pos.add_child(entry)
		entry.translate(Vector2(0,offset))
		offset=offset+350;
		entry.start.connect(selectAcc)
	pass;
func _on_account_input_text_submitted(new_text):
	var accs=loadAccs()
	saveNewAcc(new_text)
	refreshAccountList()
	pass # Replace with function body.


func HideAccounts():
	accountsTab.visible=false;
	main.visible=true
	
	pass # Replace with function body.


func _on_unlocked_tab_visibility_changed():
	
	pass # Replace with function body.


func _on_button_pressed():
	pass # Replace with function body.


func hideUnlocks():
	unlockedTab.visible=false;
	main.visible=true;
	pass # Replace with function body.




func _on_account_list_item_activated(index):
	var selected=$MainMenu/AccountsTab/AccountList.get_item_text(index)
	selectAcc(selected)
	
	pass # Replace with function body.



func _on_account_input_focus_entered():
	create_tween().tween_property($MainMenu/AccountsTab/Sprite2D/accountlight,"energy",1.4,0.5)
	pass # Replace with function body.


func _on_account_input_focus_exited():
	create_tween().tween_property($MainMenu/AccountsTab/Sprite2D/accountlight,"energy",0,1.5)
	pass # Replace with function body.
static var blinking=true;
func blinkHint(show):
	if not blinking:
		$MainMenu/AccountsTab/typehint.visible=false;
		return;
	$MainMenu/AccountsTab/typehint.visible=show
	create_tween().tween_callback(blinkHint.bind(!show)).set_delay(0.5)
	pass;
func _on_account_input_text_changed(new_text):
	if new_text=="":
		blinking=true;
		blinkHint(true);
	else:blinking=false;	
	$MainMenu/AccountsTab/accountnametext.text=new_text
	pass # Replace with function body.
